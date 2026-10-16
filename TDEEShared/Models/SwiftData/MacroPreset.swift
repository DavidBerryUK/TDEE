import SwiftData
import Foundation

/// Represents a macro split preset for the app.
/// This is a SwiftData entity that can be persisted to the local database.
/// Calories are not stored: they are derived from the TDEE calculation.
@Model
public final class MacroPreset {
    /// Unique identifier for the preset.
    public var id: UUID

    /// Human-readable name of the preset.
    public var name: String

    /// Macro split percentages.
    public var protein: Int16
    public var carbs: Int16
    public var fats: Int16

    /// Ordinal for sorting presets.
    public var ordinal: Int16

    /// Whether this is a custom preset.
    public var isCustom: Bool

    /// System-generated identifier for built-in presets.
    public var systemId: String?

    /// Date when this preset was created.
    public var createdAt: Date

    /// Date when this preset was last updated.
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        protein: Int,
        carbs: Int,
        fats: Int,
        ordinal: Int = 0,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.protein = Int16(protein)
        self.carbs = Int16(carbs)
        self.fats = Int16(fats)
        self.ordinal = Int16(ordinal)
        self.isCustom = isCustom
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
