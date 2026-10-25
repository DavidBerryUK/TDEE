//
//  TdeeResult.swift
//  TDEE
//
//  Created by David Berry on 25/04/2026.
//

import Foundation
import Observation

/// Model holding the results of a TDEE and macro calculation.
///
/// This observable class contains all calculated values including BMR, TDEE,
/// adjusted calories, and macro targets (percentages and grams).
@Observable
final class CalculatorResultViewModel {

    //
    // Basic Calculations Results
    //
    /// The Basal Metabolic Rate in calories per day
    var bmr: Double = 0
    /// The Total Daily Energy Expenditure in calories per day
    var tdee: Double = 0
    /// The adjusted calorie target after applying calorie adjustment method
    var adjustedCalories: Double = 0

    //
    // Macro Calculation Results
    //
    /// The percentage of protein in the daily calorie target
    var proteinPercent: Int = 0
    /// The percentage of carbs in the daily calorie target
    var carbsPercent: Int = 0
    /// The percentage of fats in the daily calorie target
    var fatsPercent: Int = 0
    /// The protein target in grams
    var proteinGrams: Int = 0
    /// The carbs target in grams
    var carbsGrams: Int = 0
    /// The fats target in grams
    var fatsGrams: Int = 0
    /// The adjusted calories per day (integer)
    var caloriesAdjustedPerDay: Int = 0
    /// The adjusted calories per week (integer)
    var caloriesAdjustedPerWeek: Int = 0

    //
    // Error Message
    //
    /// An error message if calculation failed, otherwise nil
    var message: String?

    init() {
        self.message = nil
    }

    /// Updates the error message for this result.
    /// - Parameter message: The error message to set
    func updateErrorMessage(message: String) {
        self.message = message
    }

    /// Updates the basic calculation results (BMR, TDEE, adjusted calories).
    /// - Parameters:
    ///   - bmr: The Basal Metabolic Rate
    ///   - tdee: The Total Daily Energy Expenditure
    ///   - adjustedCalories: The adjusted calorie target
    func updateTdee(
        bmr: Double = 0,
        tdee: Double = 0,
        adjustedCalories: Double = 0,
        ) {
        self.bmr = bmr
        self.tdee = tdee
        self.adjustedCalories = adjustedCalories

    }

    /// Updates the macro calculation results.
    /// - Parameters:
    ///   - proteinPercent: Protein percentage of calories
    ///   - carbsPercent: Carbs percentage of calories
    ///   - fatsPercent: Fats percentage of calories
    ///   - proteinGrams: Protein target in grams
    ///   - carbsGrams: Carbs target in grams
    ///   - fatsGrams: Fats target in grams
    ///   - caloriesAdjustedPerDay: Adjusted calories per day
    ///   - caloriesAdjustedPerWeek: Adjusted calories per week
    func updateMacros(
        proteinPercent: Int,
        carbsPercent: Int,
        fatsPercent: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatsGrams: Int,
        caloriesAdjustedPerDay: Int,
        caloriesAdjustedPerWeek: Int
    ) {
        self.proteinPercent = proteinPercent
        self.carbsPercent = carbsPercent
        self.fatsPercent = fatsPercent
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatsGrams = fatsGrams
        self.caloriesAdjustedPerDay = caloriesAdjustedPerDay
        self.caloriesAdjustedPerWeek = caloriesAdjustedPerWeek
    }
}
