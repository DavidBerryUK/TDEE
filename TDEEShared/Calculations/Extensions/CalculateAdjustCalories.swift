//
//  CalculateAdjustCalories.swift
//  TDEE
//
//  Created by David Berry on 30/06/2026.
//

import Foundation

extension ProfileViewModel {
    /// Adjusts base calories based on the user's calorie adjustment method.
    ///
    /// - Parameter base: The base calorie value (typically TDEE)
    /// - Returns: The adjusted calorie value (never negative)
    func adjustCalories(base: Double) -> Double {
        switch self.calorieAdjustmentMethod {
        case .maintain:
            return max( 0, base)
        case .bulk:
            return max( 0, base + Double(self.calorieAdjustment))
        case .cut:
            return max( 0, base - Double(self.calorieAdjustment))
        }
    }
}
