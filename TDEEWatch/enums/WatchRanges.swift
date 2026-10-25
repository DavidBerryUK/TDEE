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

    // Non-metric wheel options, matching the iPhone pickers (UIWheelPickerWeight/HeightView).
    static let weightPounds = Array(0...550)
    static let weightStones = Array(0...40)
    static let weightStonePounds = Array(0...13)
    static let heightInches = Array(0...107)
    static let heightFeet = Array(0...8)
    static let heightFeetInches = Array(0...11)
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
    /// The wheel's low/high bounds as non-optionals — the stride is always non-empty, so callers need
    /// not force-unwrap `adjustment.first`/`.last`. The `?? 25`/`?? 1000` fallbacks are the stride's own
    /// endpoints, so an emptied stride degrades to the same range instead of crashing (PA-23).
    static let adjustmentMin = adjustment.first ?? 25
    static let adjustmentMax = adjustment.last ?? 1000
    static let startingAdjustment = 250.0

    /// The activity levels the watch offers. ActivityLevel also has older near-duplicates
    /// (Light, Moderate, Active, Very Active) that use the same multipliers as these.
    static let activityLevels: [ActivityLevel] = [.sedentary, .lightExercise, .moderateExercise, .heavyExercise, .athlete]
}
