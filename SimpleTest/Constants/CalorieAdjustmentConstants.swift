//
//  CalorieAdjustmentConstants.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

/// Constants for calorie adjustment slider ranges
enum CalorieAdjustmentConstants {
    /// Minimum calorie adjustment (0 calories/day)
    static let minAdjustment: Double = 0
    /// Maximum calorie adjustment (1000 calories/day)
    static let maxAdjustment: Double = 1000
    /// Slider step increment (25 calories/day)
    static let adjustmentStep: Double = 25
}
