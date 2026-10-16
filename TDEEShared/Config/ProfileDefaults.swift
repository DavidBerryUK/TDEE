//
//  ProfileDefaults.swift
//  TDEE
//
//  Created by David Berry on 11 Oct 2026.
//

import Foundation

/// Represents default values for user profile metrics.
/// Different values are provided for simulator vs. physical device contexts.
struct ProfileDefaults: Sendable {
    let gender: Gender
    let age: Int
    let height: Double
    let weight: Double
    let activityLevel: ActivityLevel
    let bodyFatPercentage: Double
    let bodyFatPercentageMethod: BodyFatOption
    let calorieAdjustmentMethod: CalorieAdjustmentMethod

    static func simulator() -> ProfileDefaults {
        ProfileDefaults(
            gender: .male,
            age: 25,
            height: 175.0,
            weight: 70.0,
            activityLevel: .moderateExercise,
            bodyFatPercentage: 15.0,
            bodyFatPercentageMethod: .omit,
            calorieAdjustmentMethod: .maintain
        )
    }

    static func device() -> ProfileDefaults {
        ProfileDefaults(
            gender: .male,
            age: 16,
            height: 0.0,
            weight: 0.0,
            activityLevel: .sedentary,
            bodyFatPercentage: 0.0,
            bodyFatPercentageMethod: .omit,
            calorieAdjustmentMethod: .maintain
        )
    }
}
