import SwiftData
import Foundation

/// Represents a macro breakdown configuration.
/// Stored as separate Int16 properties in SwiftData since classes can't be persisted directly.
public final class MacroBreakdown: Sendable {
    public let calories: Int
    public let carbs: Int
    public let fat: Int
    public let protein: Int

    public init(
        calories: Int,
        carbs: Int,
        fat: Int,
        protein: Int
    ) {
        self.calories = calories
        self.carbs = carbs
        self.fat = fat
        self.protein = protein
    }
}

/// Represents a macro configuration preset for the app.
/// This is a SwiftData entity that can be persisted to the local database.
@Model
public final class MacroPreset {
    /// Unique identifier for the preset.
    public var id: UUID

    /// Human-readable name of the preset.
    public var name: String

    /// Primary macro breakdown for this preset (stored as separate properties).
    public var primaryCalories: Int16
    public var primaryCarbs: Int16
    public var primaryFat: Int16
    public var primaryProtein: Int16

    /// Secondary macro breakdown for this preset (stored as separate properties).
    public var secondaryCalories: Int16?
    public var secondaryCarbs: Int16?
    public var secondaryFat: Int16?
    public var secondaryProtein: Int16?

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

    /// Creates a new macro preset with the given parameters.
    /// - Parameters:
    ///   - id: Unique identifier for the preset.
    ///   - name: Name of the preset.
    ///   - primaryBreakdown: Primary macro breakdown.
    ///   - secondaryBreakdown: Optional secondary macro breakdown.
    ///   - ordinal: Sort order ordinal.
    ///   - isCustom: Whether this is a custom user preset.
    public init(
        id: UUID = UUID(),
        name: String,
        primaryBreakdown: MacroBreakdown,
        secondaryBreakdown: MacroBreakdown? = nil,
        ordinal: Int16 = 0,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.primaryCalories = Int16(primaryBreakdown.calories)
        self.primaryCarbs = Int16(primaryBreakdown.carbs)
        self.primaryFat = Int16(primaryBreakdown.fat)
        self.primaryProtein = Int16(primaryBreakdown.protein)
        self.secondaryCalories = secondaryBreakdown.map { Int16($0.calories) }
        self.secondaryCarbs = secondaryBreakdown.map { Int16($0.carbs) }
        self.secondaryFat = secondaryBreakdown.map { Int16($0.fat) }
        self.secondaryProtein = secondaryBreakdown.map { Int16($0.protein) }
        self.ordinal = ordinal
        self.isCustom = isCustom
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Returns the primary breakdown as a MacroBreakdown instance.
    public var primaryBreakdown: MacroBreakdown {
        MacroBreakdown(
            calories: Int(primaryCalories),
            carbs: Int(primaryCarbs),
            fat: Int(primaryFat),
            protein: Int(primaryProtein)
        )
    }

    /// Returns the secondary breakdown as a MacroBreakdown instance.
    public var secondaryBreakdown: MacroBreakdown? {
        guard let calories = secondaryCalories,
              let carbs = secondaryCarbs,
              let fat = secondaryFat,
              let protein = secondaryProtein else {
            return nil
        }
        return MacroBreakdown(
            calories: Int(calories),
            carbs: Int(carbs),
            fat: Int(fat),
            protein: Int(protein)
        )
    }
}

/// Defines the possible options for macro split configurations.
/// The app uses this to configure the primary and secondary breakdowns.
public enum OptionMacroSplit {
    case maintain
    case weightLoss
    case muscleGain
    case performance
}
