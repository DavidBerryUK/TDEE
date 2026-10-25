import SwiftData
import Foundation

@Model
public class Profile {
    /// Human-readable name identifying this profile (e.g. "Main", "Me", "Partner").
    /// The Main profile is the one named "Main" — see ProfileRepository.mainProfileName.
    public var name: String

    /// User's gender (0 = male, 1 = female)
    public var gender: Int16

    /// User's age in years
    public var age: Int

    /// User's height in centimetres
    public var height: Double

    /// Height unit of measure (OptionLength raw value: 0 = cm, 1 = in, 2 = ft & in).
    public var heightUomRaw: Int = 0

    /// Transient property for OptionLength access; decodes with a safe fallback to centimetres.
    public var heightUom: OptionLength {
        get { OptionLength(rawValue: heightUomRaw) ?? .centimeters }
        set { heightUomRaw = newValue.rawValue }
    }

    /// User's weight in kilograms
    public var weight: Double

    /// Weight unit of measure (OptionWeight raw value: 0 = kg, 1 = lb, 2 = stones & lb).
    public var weightUomRaw: Int = 0

    /// Transient property for OptionWeight access; decodes with a safe fallback to kilograms.
    public var weightUom: OptionWeight {
        get { OptionWeight(rawValue: weightUomRaw) ?? .kilograms }
        set { weightUomRaw = newValue.rawValue }
    }

    /// Body fat percentage (0.0-100.0)
    public var bodyFatPercentage: Double

    /// Activity level (stored as raw value string)
    public var activityLevelRaw: String

    /// Transient property for ActivityLevel access.
    ///
    /// Decoded via `ActivityLevel.from(storedRaw:)`, which maps the legacy
    /// near-duplicate raws removed in PA-10 to their equivalent level, so a
    /// profile saved on an older build still computes the same TDEE.
    public var activityLevel: ActivityLevel {
        get { ActivityLevel.from(storedRaw: activityLevelRaw) }
        set { activityLevelRaw = newValue.rawValue }
    }

    /// Body fat method (BodyFatOption raw value)
    public var bodyFatMethodRaw: Int

    /// Calorie adjustment method (CalorieAdjustmentMethod raw value)
    public var calorieAdjustmentMethodRaw: Int

    /// Calorie adjustment amount per day
    public var calorieAdjustment: Double

    /// The selected macro split preset
    public var selectedMacroId: UUID

    /// Unique identifier for this profile
    public var id: UUID

    /// When this profile was created
    public var createdAt: Date

    /// When this profile was last updated
    public var updatedAt: Date

    /// Create a new profile instance
    public init(
        name: String = "Main",  // Default to the Main profile; matches ProfileRepository.mainProfileName.
        gender: Int16,
        age: Int,
        height: Double,
        heightUom: OptionLength = .centimeters,
        weight: Double,
        weightUom: OptionWeight = .kilograms,
        bodyFatPercentage: Double = 0.0,
        activityLevel: ActivityLevel = .sedentary,
        bodyFatMethod: BodyFatOption = .omit,
        calorieAdjustmentMethod: CalorieAdjustmentMethod = .maintain,
        calorieAdjustment: Double = 0,
        selectedMacroId: UUID,
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.name = name
        self.gender = gender
        self.age = age
        self.height = height
        self.heightUomRaw = heightUom.rawValue
        self.weight = weight
        self.weightUomRaw = weightUom.rawValue
        self.bodyFatPercentage = bodyFatPercentage
        self.activityLevelRaw = activityLevel.rawValue
        self.bodyFatMethodRaw = bodyFatMethod.rawValue
        self.calorieAdjustmentMethodRaw = calorieAdjustmentMethod.rawValue
        self.calorieAdjustment = calorieAdjustment
        self.selectedMacroId = selectedMacroId
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}