//
//  CalculateMacros.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

extension ProfileViewModel {
    
    func calculateMacros(result: CalculatorResultViewModel) {
        
        let caloriesAdjustedPerDay : Int =  Int(result.adjustedCalories)
        let caloriesAdjustedPerWeek : Int = caloriesAdjustedPerDay * 7
        
        let proteinPercent: Int = 40
        let carbsPercent: Int = 40
        let fatsPercent: Int = 20 // Adjusted to ensure total is 100%
        
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
