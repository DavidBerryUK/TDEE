//
//  CalculateKatchMcArdle.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

import Foundation

extension ProfileViewModel {
    /// Calculates Basal Metabolic Rate using the Katch-McArdle formula.
    ///
    /// - Parameter logger: The audit logger for tracking calculation steps
    /// - Returns: The BMR in calories per day
    func calculateKatchMcArdle( logger: AuditLogger) -> Double {
        // Logger log removed for brevity

        let lbm = self.calculateLeanBodyMass(logger: logger)
        let bmr = 370 + (21.6 * lbm)

        return bmr
    }
}
