//
//  MacroSplitResultViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 19/04/2026.
//

import Foundation

@Observable
final class MacroSplitResultViewModel {
    var proteinPercent: Int = 0
    var carbsPercent: Int = 0
    var fatsPercent: Int = 0
    var proteinGrams: Int = 0
    var carbsGrams: Int = 0
    var fatsGrams: Int = 0
    var calories: Int = 0
    var caloriesAdjustedPerDay: Int = 0
    var caloriesAdjustedPerWeek: Int = 0
    
    init() {
        self.proteinPercent = 0
        self.carbsPercent = 0
        self.fatsPercent = 0
        self.proteinGrams = 0
        self.carbsGrams = 0
        self.fatsGrams = 0
        self.calories = 0
        self.caloriesAdjustedPerDay = 0
        self.caloriesAdjustedPerWeek = 0
    }
    
    init(
        proteinPercent: Int,
        carbsPercent: Int,
        fatsPercent: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatsGrams: Int,
        calories: Int,
        caloriesAdjustedPerDay: Int,
        caloriesAdjustedPerWeek: Int
    ) {
        self.proteinPercent = proteinPercent
        self.carbsPercent = carbsPercent
        self.fatsPercent = fatsPercent
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatsGrams = fatsGrams
        self.calories = calories
        self.caloriesAdjustedPerDay = caloriesAdjustedPerDay
        self.caloriesAdjustedPerWeek = caloriesAdjustedPerWeek
    }
}
