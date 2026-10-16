//
//  CalculateMifflinStJeor.swift
//  TDEE
//
//  Created by David Berry on 30/06/2026.
//

import Foundation

extension ProfileViewModel {
    /// Calculates Basal Metabolic Rate using the Mifflin-St Jeor equation.
    ///
    /// - Parameter logger: The audit logger for tracking calculation steps
    /// - Returns: The BMR in calories per day
    func calculateMifflinStJeor(logger: AuditLogger) -> Double {
        // Logger log removed for brevity

        let weight = self.weight
        let height = self.height
        let age = Double(self.age)
        let adjustment = self.gender == .male ? 5.0 : -161.0

        let bmr = 10.0 * weight + 6.25 * height - 5.0 * age + adjustment

        return bmr
    }
}
