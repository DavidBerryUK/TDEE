import SwiftData
import Foundation

/// Maps between MacroSplitOptionModel and SwiftData MacroPreset entity
enum MacroPresetMapper {
    /// Convert entity to model for reading from SwiftData
    static func mapToModel(_ entity: MacroPreset) -> MacroSplitOptionModel {
        MacroSplitOptionModel(
            id: entity.id,
            name: entity.name,
            protein: Int(entity.primaryProtein),
            carbs: Int(entity.primaryCarbs),
            fats: Int(entity.primaryFat),
            ordinal: Int(entity.ordinal),
            isSelected: false,  // Selection managed separately
            isCustom: entity.isCustom
        )
    }

    /// Convert model to entity for saving to SwiftData
    /// Note: Presets are shared, so no owner is set
    static func mapToEntity(_ model: MacroSplitOptionModel) -> MacroPreset {
        let breakdown = MacroBreakdown(
            calories: 2000,  // Placeholder - calories not stored in model
            carbs: model.carbs,
            fat: model.fats,
            protein: model.protein
        )
        let preset = MacroPreset(
            id: model.id,
            name: model.name,
            primaryBreakdown: breakdown,
            ordinal: Int16(model.ordinal),
            isCustom: model.isCustom
        )
        preset.updatedAt = Date()
        return preset
    }

    /// Create a system preset entity from seed data
    static func mapSystemPresetToEntity(id: UUID, name: String, protein: Int, carbs: Int, fats: Int, ordinal: Int) -> MacroPreset {
        let breakdown = MacroBreakdown(
            calories: 2000,  // Placeholder
            carbs: carbs,
            fat: fats,
            protein: protein
        )
        let preset = MacroPreset(
            id: id,
            name: name,
            primaryBreakdown: breakdown,
            ordinal: Int16(ordinal),
            isCustom: false
        )
        preset.systemId = name.lowercased().replacingOccurrences(of: " ", with: "_")
        preset.createdAt = Date()
        preset.updatedAt = Date()
        return preset
    }
}
