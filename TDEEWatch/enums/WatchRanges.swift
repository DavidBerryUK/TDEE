//
//  WatchRanges.swift
//  TDEE Watch
//
//

import SwiftUI

// Weight is stored in kg and height in cm. The watch edits those units directly.
// Ranges match the iPhone wheel pickers.

internal enum WatchRanges {
    static let age = Array(16...99)
    static let weightKg = Array(0...250)
    static let heightCm = Array(0...272)
    /// Whole percent. The calculation only accepts 5-50% (`validateForCalculation`).
    static let bodyFatInteger = Array(5...50)
    static let bodyFatDecimal = Array(0...9)
    /// Same limits as `CalorieAdjustmentConstants` on the iPhone (that file is iPhone-only).
    /// Accepted body fat percentage, matching `validateForCalculation`.
    static let bodyFatPercent = 5.0...50.0

    // Where an empty (0) value starts when its screen opens, so the user scrolls a little, not from 0.
    static let startingWeightKg = 70.0
    static let startingHeightCm = 170.0
    static let startingBodyFatPercent = 20.0

    /// Cut or bulk by 25-1000 kcal. 0 would be the same as Maintain.
    static let adjustment = Array(stride(from: 25, through: 1000, by: 25))
    static let startingAdjustment = 250.0

    /// The activity levels the watch offers. ActivityLevel also has older near-duplicates
    /// (Light, Moderate, Active, Very Active) that use the same multipliers as these.
    static let activityLevels: [ActivityLevel] = [.sedentary, .lightExercise, .moderateExercise, .heavyExercise, .athlete]
}
