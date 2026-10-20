//
//  CalculationValidatePerson.swift
//  TDEE
//
//  Created by David Berry on 30/06/2026.
//

import Foundation

extension ProfileViewModel {
    /// Validates required fields for calculation.
    /// - Returns: An error message listing invalid/missing fields, or `nil` if all fields are valid.
    /// Fields are invalid if:
    /// - Age is 0, or Height or Weight is outside its accepted range (story 023, inputs #4 / #6)
    /// - Body Fat Percentage is outside the valid range (5-50%) when using manual entry method
    func validateForCalculation() -> String? {
        var fields: [String] = []
        if self.age == 0 { fields.append("Age") }
        // Kept in sync with isHeightValid (Decision 14 analog): both gate on the shared MetricRanges.height.
        if !MetricRanges.height.contains(self.height) { fields.append("Height") }
        // Kept in sync with isWeightValid (Decision 14): both gate on the shared MetricRanges.weight.
        if !MetricRanges.weight.contains(self.weight) { fields.append("Weight") }
        // Only validate body fat percentage when manual entry method is selected (Decision 21).
        // Kept in sync with isBodyFatValid: both gate on the shared MetricRanges.bodyFatPercentage
        // (5–50%, physiologically realistic for adults), and only under Manual Entry.
        if self.bodyFatPercentageMethod == .manualEntry, !MetricRanges.bodyFatPercentage.contains(self.bodyFatPercentage) {
            fields.append("Body Fat Percentage")
        }

        if fields.isEmpty {
            return nil
        }

        let errorString = "Following fields are mandatory: " + fields.joined(separator: ", ")
        return errorString
    }
}
