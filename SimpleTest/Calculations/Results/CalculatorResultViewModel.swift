//
//  TdeeResult.swift
//  SimpleTest
//
//  Created by David Berry on 25/04/2026.
//

import Foundation
import Observation

/// Model holding the results of a TDEE and macro calculation.
@Observable
final class CalculatorResultViewModel {

    //
    // Basic Calculations Results
    //
    var bmr: Double = 0
    var tdee: Double = 0
    var adjustedCalories: Double = 0

    //
    // Macro Calculation Results
    //
    var proteinPercent: Int = 0
    var carbsPercent: Int = 0
    var fatsPercent: Int = 0
    var proteinGrams: Int = 0
    var carbsGrams: Int = 0
    var fatsGrams: Int = 0
    var caloriesAdjustedPerDay: Int = 0
    var caloriesAdjustedPerWeek: Int = 0

    //
    // Auditing
    //
    var audit: [AuditItem]

    //
    // Error Message
    //
    var message: String?

    init() {
        self.message = nil
        self.audit = []
    }

    func updateErrorMessage(message: String) {
        self.message = message
    }

    func updateTdee(
        bmr: Double = 0,
        tdee: Double = 0,
        adjustedCalories: Double = 0,
        ) {
        self.bmr = bmr
        self.tdee = tdee
        self.adjustedCalories = adjustedCalories

    }

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
