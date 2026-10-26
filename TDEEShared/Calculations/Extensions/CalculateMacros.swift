//
//  CalculateMacros.swift
//  TDEE
//
//  Created by David Berry on 30/06/2026.
//

import Foundation

extension ProfileViewModel {
    /// Calculates macro targets from TDEE and updates the result model.
    ///
    /// - Parameter result: The result model to update with macro calculations
    func calculateMacros(result: CalculatorResultViewModel) {

        let caloriesAdjustedPerDay: Int = Int(result.adjustedCalories)
        let caloriesAdjustedPerWeek: Int = caloriesAdjustedPerDay * 7

        // adjustedCalories is always >= 0 — adjustCalories clamps via max(0, …) on every
        // branch — so no negative guard is needed here.
        // Use the profile's stored macro split
        let proteinPercent: Int = protein
        let carbsPercent: Int = carbs
        let fatsPercent: Int = fats

        // Calculate grams: (percent / 100) * calories / cal per gram
        // Protein and carbs: 4 cal/g, Fats: 9 cal/g
        let proteinGrams = Int(Double(proteinPercent) * Double(caloriesAdjustedPerDay) / 100 / 4)
        let carbsGrams = Int(Double(carbsPercent) * Double(caloriesAdjustedPerDay) / 100 / 4)
        let fatsGrams = Int(Double(fatsPercent) * Double(caloriesAdjustedPerDay) / 100 / 9)

        result.updateMacros(
            proteinPercent: proteinPercent,
            carbsPercent: carbsPercent,
            fatsPercent: fatsPercent,
            proteinGrams: proteinGrams,
            carbsGrams: carbsGrams,
            fatsGrams: fatsGrams,

            caloriesAdjustedPerDay: caloriesAdjustedPerDay,
            caloriesAdjustedPerWeek: caloriesAdjustedPerWeek
        )
    }
}
