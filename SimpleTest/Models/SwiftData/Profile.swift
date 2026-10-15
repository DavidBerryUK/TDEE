import SwiftData
import Foundation

@Model
public class Profile {
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

    /// Unique identifier for this profile
    public var id: UUID

    /// When this profile was created
    public var createdAt: Date

    /// When this profile was last updated
    public var updatedAt: Date

    /// Create a new profile instance
    public init(
        gender: Int16,
        age: Int,
        height: Double,
        weight: Double,
        bodyFatPercentage: Double = 0.0,
        activityLevel: ActivityLevel = .sedentary,
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.gender = gender
        self.age = age
        self.height = height
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.activityLevelRaw = activityLevel.rawValue
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}