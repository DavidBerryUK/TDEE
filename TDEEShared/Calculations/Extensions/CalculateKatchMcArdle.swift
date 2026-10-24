//
//  CalculateKatchMcArdle.swift
//  TDEE
//
//  Created by David Berry on 30/06/2026.
//

import Foundation

extension ProfileViewModel {
    /// Calculates Basal Metabolic Rate using the Katch-McArdle formula.
    ///
    /// - Returns: The BMR in calories per day
    func calculateKatchMcArdle() -> Double {

        let lbm = self.calculateLeanBodyMass()
        let bmr = 370 + (21.6 * lbm)

        return bmr
    }
}
