import Observation
import Foundation
import SwiftUI

/// Collection of all the Macro Split Options
@Observable
@MainActor
final class MacroSplitOptionsModelCollection {

    // Source of truth
    public var items: [MacroSplitOptionModel] = []

    private var profileRepository: ProfileRepository?

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
            print("Failed to load presets, using factory presets in memory: \(error)")
            self.items = FactoryMacroSplits.get()
        }
    }

    /// Replace all presets (edited, deleted and custom) with the factory presets.
    func resetToDefaults() async {
        await flush()
        if let repository = profileRepository {
            do {
                try await repository.resetPresetsToDefaults()
            } catch {
                print("Failed to reset presets: \(error)")
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
            print("Failed to save presets: \(error)")
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
            catch { print("Failed to delete preset: \(error)") }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        var updated = sortedItems
        updated.move(fromOffsets: source, toOffset: destination)

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
