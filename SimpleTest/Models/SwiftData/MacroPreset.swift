import Foundation
import SwiftData

@Model
class MacroPreset {
    var id: UUID
    var name: String
    var protein: Int16
    var carbs: Int16
    var fats: Int16
    var ordinal: Int
    var isCustom: Bool
    var systemId: String?  // e.g., "balanced", "diet" for system presets
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        name: String,
        protein: Int16,
        carbs: Int16,
        fats: Int16,
        ordinal: Int,
        isCustom: Bool,
        systemId: String? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.ordinal = ordinal
        self.isCustom = isCustom
        self.systemId = systemId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // For testing and initialization purposes
    init() {
        self.id = UUID()
        self.name = ""
        self.protein = 0
        self.carbs = 0
        self.fats = 0
        self.ordinal = 0
        self.isCustom = false
        self.systemId = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}