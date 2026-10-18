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

    /// User's height in meters
    public var height: Double

    /// User's weight in kilograms
    public var weight: Double

    /// Body fat percentage (0.0-100.0)
    public var bodyFatPercentage: Double

    /// Activity level (stored as raw value string)
    public var activityLevelRaw: String

    /// Transient property for ActivityLevel access
    public var activityLevel: ActivityLevel {
        get { ActivityLevel(rawValue: activityLevelRaw) ?? .sedentary }
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
        weight: Double,
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
        self.weight = weight
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