import Foundation
import SwiftData

@Model
class Profile {
    var id: UUID
    var gender: Int16
    var age: Int16
    var height: Double
    var weight: Double
    var activityLevel: Int16
    var bodyFatPercentage: Double?
    var bodyFatMethod: Int16?
    var name: String?
    var seedVersion: Int16  // Track which version of seed data was applied
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        gender: Int16,
        age: Int16,
        height: Double,
        weight: Double,
        activityLevel: Int16,
        bodyFatPercentage: Double? = nil,
        bodyFatMethod: Int16? = nil,
        name: String? = nil,
        seedVersion: Int16,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.gender = gender
        self.age = age
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.bodyFatPercentage = bodyFatPercentage
        self.bodyFatMethod = bodyFatMethod
        self.name = name
        self.seedVersion = seedVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // For testing and initialization purposes
    init() {
        self.id = UUID()
        self.gender = 0
        self.age = 0
        self.height = 0.0
        self.weight = 0.0
        self.activityLevel = 0
        self.bodyFatPercentage = nil
        self.bodyFatMethod = nil
        self.name = nil
        self.seedVersion = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}