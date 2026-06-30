//
//  CalculateKatchMcArdle.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

extension ProfileViewModel {
    func calculateKatchMcArdle( logger: AuditLogger) -> Double {
        // Logger log removed for brevity
        
        let lbm = self.calculateLeanBodyMass(logger: logger)
        let bmr = 370 + (21.6 * lbm)

        return bmr
    }
}
