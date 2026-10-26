import Observation
import Foundation
import os

/// Collection of all the Macro Split Options
@Observable
@MainActor
final class MacroSplitOptionsModelCollection {

    // Source of truth
    public var items: [MacroSplitOptionModel] = []

    /// A transient, user-facing message when a preset load/reset/save/delete fails to persist.
    /// Non-blocking: the UI surfaces it briefly and clears it; a failed operation never halts the app.
    var notice: String?

    private var profileRepository: ProfileRepository?

    /// Error-logging channel for a preset load/reset/save/delete that fails to persist
    /// (lost in a release build via `print`).
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DaveBerryUk.TDEE", category: "MacroSplitOptionsModelCollection")

    var sortedItems: [MacroSplitOptionModel] {
        items.sorted { $0.ordinal < $1.ordinal }
    }

    // Default empty (for backward compatibility)
    init() {
        self.items = []
    }

    // Initialise with existing items (for backward compatibility)
    init(items: [MacroSplitOptionModel]) {
        self.items = items
    }

    /// New initializer with persistence support
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
        self.items = []
        // Caller must await loadPresets() before using items
    }

    /// Load presets from SwiftData (presets are a shared catalog).
    /// Seeds the factory presets when the store is empty.
    func loadPresets() async {
        guard let repository = profileRepository else { return }
        do {
            try await repository.seedPresetsIfEmpty()
            let presets = try await repository.fetchPresets()
            self.items = presets.map { MacroPresetMapper.mapToModel($0) }
        } catch {
            Self.logger.error("Failed to load presets, using factory presets in memory: \(error)")
            self.items = FactoryMacroSplits.get()
            notice = "Couldn't load your saved macro presets. Using the defaults."
        }
    }

    /// Replace all presets (edited, deleted and custom) with the factory presets.
    func resetToDefaults() async {
        await flush()
        if let repository = profileRepository {
            do {
                try await repository.resetPresetsToDefaults()
            } catch {
                Self.logger.error("Failed to reset presets: \(error)")
                notice = "Couldn't reset your macros to the defaults."
                return
            }
        }
        items = FactoryMacroSplits.get()
    }

    // MARK: - Persistence queue

    private var pending: Task<Void, Never>?

    /// Run persistence work in order, so saves never overtake each other.
    private func enqueue(_ work: @escaping @MainActor () async -> Void) {
        guard profileRepository != nil else { return }
        let previous = pending
        pending = Task { @MainActor in
            await previous?.value
            await work()
        }
    }

    /// Wait for all queued saves and deletes to finish.
    func flush() async {
        await pending?.value
    }

    private func persist(_ presets: [MacroSplitOptionModel]) async {
        guard let repository = profileRepository else { return }
        do {
            for preset in presets {
                try await repository.savePreset(MacroPresetMapper.mapToEntity(preset))
            }
        } catch {
            Self.logger.error("Failed to save presets: \(error)")
            notice = "Couldn't save your macro changes."
        }
    }

    // MARK: - CRUD

    func add(_ item: MacroSplitOptionModel) {
        item.ordinal = -1
        items.append(item)
        reindex()
        // Reindexing changes other ordinals, so persist everything
        let all = items
        enqueue { [weak self] in await self?.persist(all) }
    }

    private func reindex() {
        let sorted = items.sorted { $0.ordinal < $1.ordinal }

        for (index, item) in sorted.enumerated() {
            item.ordinal = index
        }
    }

    func update(_ item: MacroSplitOptionModel) {
        guard let existing = items.first(where: { $0.id == item.id }) else {
            // Not in the collection yet (new macro from the editor)
            item.isCustom = true
            add(item)
            return
        }
        existing.name = item.name
        existing.protein = item.protein
        existing.carbs = item.carbs
        existing.fats = item.fats
        existing.ordinal = item.ordinal
        existing.isSelected = item.isSelected
        enqueue { [weak self] in await self?.persist([existing]) }
    }

    /// Removes a macro. The last remaining macro cannot be removed.
    func remove(_ item: MacroSplitOptionModel) {
        guard items.count > 1,
              let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items.remove(at: index)
        let id = item.id
        enqueue { [weak self] in
            guard let repository = self?.profileRepository else { return }
            do { try await repository.deletePreset(id: id) }
            catch {
                Self.logger.error("Failed to delete preset: \(error)")
                self?.notice = "Couldn't delete that macro."
            }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        var updated = sortedItems
        // Same result as SwiftUI's move(fromOffsets:toOffset:), without importing SwiftUI
        let moving = source.sorted().map { updated[$0] }
        let removedBeforeDestination = source.filter { $0 < destination }.count
        source.sorted(by: >).forEach { updated.remove(at: $0) }
        updated.insert(contentsOf: moving, at: destination - removedBeforeDestination)

        // Reassign ordinals
        for (index, item) in updated.enumerated() {
            item.ordinal = index
        }

        items = updated
        enqueue { [weak self] in await self?.persist(updated) }
    }

    // MARK: - Selection

    func selectItem(byId id: UUID) {
        items.forEach { $0.isSelected = ($0.id == id) }
    }

    func selectFirstItem() {
        guard let first = items.first else { return }
        selectItem(byId: first.id)
    }

    func clearSelection() {
        items.forEach { $0.isSelected = false }
    }
}
