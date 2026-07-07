//
//  CalculateLeanBodyMass.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

extension ProfileViewModel {
    func validateForCalculation() -> String? {
        var fields: [String] = []
        if self.age == 0 { fields.append("Age") }
        if self.height == 0 { fields.append("Height") }
        if self.weight == 0 { fields.append("Weight") }
        if self.bodyFatPercentage < 2 || self.bodyFatPercentage > 60 { fields.append("Body Fat Percentage") }

        if ( fields.isEmpty) {
            return nil
        }

        let errorString = "Following fields are mandatory: " + fields.joined(separator: ", ")
        return errorString
    }
}
