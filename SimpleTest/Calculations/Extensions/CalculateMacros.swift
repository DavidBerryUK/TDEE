//
//  CalculateMacros.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

extension ProfileViewModel {

    func calculateMacros(result: CalculatorResultViewModel) {

        let caloriesAdjustedPerDay: Int = Int(result.adjustedCalories)
        let caloriesAdjustedPerWeek: Int = caloriesAdjustedPerDay * 7

        // Guard against negative calorie values
        guard caloriesAdjustedPerDay >= 0 else {
            result.updateMacros(
                proteinPercent: protein,
                carbsPercent: carbs,
                fatsPercent: fats,
                proteinGrams: 0,
                carbsGrams: 0,
                fatsGrams: 0,
                caloriesAdjustedPerDay: 0,
                caloriesAdjustedPerWeek: 0
            )
            return
        }

        // Use the profile's stored macro split (synced from user selection or sliders)
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
