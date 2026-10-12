//
//  CalculateLeanBodyMass.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

extension ProfileViewModel {
    /// Validates required fields for calculation.
    /// - Returns: An error message listing invalid/missing fields, or `nil` if all fields are valid.
    /// Fields are invalid if:
    /// - Age, Height, or Weight are 0
    /// - Body Fat Percentage is outside the valid range (5-50%) when using manual entry method
    func validateForCalculation() -> String? {
        var fields: [String] = []
        if self.age == 0 { fields.append("Age") }
        if self.height == 0 { fields.append("Height") }
        if self.weight == 0 { fields.append("Weight") }
        // Only validate body fat percentage when manual entry method is selected
        // Valid range: 5-50% (physiologically realistic for adults)
        if self.bodyFatPercentageMethod == .manualEntry, self.bodyFatPercentage < 5 || self.bodyFatPercentage > 50 {
            fields.append("Body Fat Percentage")
        }

        if fields.isEmpty {
            return nil
        }

        let errorString = "Following fields are mandatory: " + fields.joined(separator: ", ")
        return errorString
    }
}
