import SwiftData
import SimpleTest
import Foundation

/// Maps between MacroSplitOptionModel and SwiftData MacroPreset entity
enum MacroPresetMapper {
    /// Convert entity to model for reading from SwiftData
    static func mapToModel(_ entity: MacroPreset) -> MacroSplitOptionModel {
        MacroSplitOptionModel(
            id: entity.id,
            name: entity.name,
            protein: Int(entity.protein),
            carbs: Int(entity.carbs),
            fats: Int(entity.fats),
            ordinal: Int(entity.ordinal), // This was the problem - converting Int16 to Int
            isSelected: false,  // Selection managed separately
            isCustom: entity.isCustom
        )
    }

    /// Convert model to entity for saving to SwiftData
    /// Note: Presets are shared, so no owner is set
    static func mapToEntity(_ model: MacroSplitOptionModel) -> MacroPreset {
        let preset = MacroPreset()
        preset.id = model.id
        preset.name = model.name
        preset.protein = Int16(model.protein)
        preset.carbs = Int16(model.carbs)
        preset.fats = Int16(model.fats)
        preset.ordinal = Int(model.ordinal) // Explicit conversion to Int16
        preset.isCustom = model.isCustom
        preset.updatedAt = Date()
        // createdAt is set when entity is created
        if preset.createdAt == Date(timeIntervalSince1970: 0) { // Default date check
            preset.createdAt = Date()
        }
        return preset
    }

    /// Create a system preset entity from seed data
    static func mapSystemPresetToEntity(id: UUID, name: String, protein: Int, carbs: Int, fats: Int, ordinal: Int) -> MacroPreset {
        let preset = MacroPreset()
        preset.id = id
        preset.name = name
        preset.protein = Int16(protein)
        preset.carbs = Int16(carbs)
        preset.fats = Int16(fats)
        preset.ordinal = Int16(ordinal)
        preset.isCustom = false
        preset.systemId = name.lowercased().replacingOccurrences(of: " ", with: "_")
        preset.createdAt = Date()
        preset.updatedAt = Date()
        return preset
    }
}
