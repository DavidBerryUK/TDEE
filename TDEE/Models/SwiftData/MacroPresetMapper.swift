import SwiftData
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
            ordinal: Int(entity.ordinal),
            isSelected: false,  // Selection managed separately
            isCustom: entity.isCustom
        )
    }

    /// Convert model to entity for saving to SwiftData
    /// Note: Presets are shared, so no owner is set
    static func mapToEntity(_ model: MacroSplitOptionModel) -> MacroPreset {
        MacroPreset(
            id: model.id,
            name: model.name,
            protein: model.protein,
            carbs: model.carbs,
            fats: model.fats,
            ordinal: model.ordinal,
            isCustom: model.isCustom
        )
    }
}
