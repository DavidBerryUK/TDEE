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

    /// Load presets from SwiftData (presets are a shared catalog)
    /// Call this after init(profileRepository:) to populate items
    func loadPresets() async {
        guard let repository = profileRepository else { return }
        do {
            var presets = try await repository.fetchPresets()
            if presets.isEmpty {
                // First launch: seed the store with the factory presets
                for model in SeedData.macroPresets() {
                    try await repository.savePreset(MacroPresetMapper.mapToEntity(model))
                }
                presets = try await repository.fetchPresets()
            }
            self.items = presets.map { MacroPresetMapper.mapToModel($0) }
        } catch {
            // Handle error - fallback to factory presets
            self.items = FactoryMacroSplits.get().map { model in
                MacroSplitOptionModel(
                    id: model.id,
                    name: model.name,
                    protein: model.protein,
                    carbs: model.carbs,
                    fats: model.fats,
                    ordinal: model.ordinal,
                    isSelected: model.isSelected,
                    isCustom: false  // Factory presets are system presets
                )
            }
        }
    }

    /// Save a preset to SwiftData (presets are shared, no owner)
    func savePreset(_ preset: MacroSplitOptionModel) async {
        guard let repository = profileRepository else { return }
        do {
            let entity = MacroPresetMapper.mapToEntity(preset)
            try await repository.savePreset(entity)
        } catch {
            // Handle error - could surface to user
            print("Failed to save preset: \(error)")
        }
    }

    /// Batch save all presets
    func saveAll(_ presets: [MacroSplitOptionModel]) async {
        guard let repository = profileRepository else { return }
        do {
            for preset in presets {
                let entity = MacroPresetMapper.mapToEntity(preset)
                try await repository.savePreset(entity)
            }
        } catch {
            // Handle error - could surface to user
            print("Failed to save presets: \(error)")
        }
    }

    // MARK: - CRUD

    func add(_ item: MacroSplitOptionModel) {
        item.ordinal = -1
        items.append(item)
        reindex()
        // Save the new preset if we have a repository
        Task {
            await savePreset(item)
        }
    }

    private func reindex() {
        let sorted = items.sorted { $0.ordinal < $1.ordinal }

        for (index, item) in sorted.enumerated() {
            item.ordinal = index
        }
    }

    func update(_ item: MacroSplitOptionModel) {
        guard items.contains(where: { $0.id == item.id }) else {
            // Not in the collection yet (new macro from the editor)
            item.isCustom = true
            add(item)
            return
        }
        if let existing = items.first(where: { $0.id == item.id }) {
            existing.name = item.name
            existing.protein = item.protein
            existing.carbs = item.carbs
            existing.fats = item.fats
            existing.ordinal = item.ordinal
            existing.isSelected = item.isSelected
        }
        // Save the updated preset if we have a repository
        Task {
            await savePreset(item)
        }
    }

    func remove(_ item: MacroSplitOptionModel) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        guard let repository = profileRepository else { return }
        let id = item.id
        Task {
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

        // Save reordered presets if we have a repository
        Task {
            await saveAll(updated)
        }
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
