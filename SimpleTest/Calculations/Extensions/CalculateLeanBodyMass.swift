//
//  CalculateLeanBodyMass.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

extension ProfileViewModel {
    func calculateLeanBodyMass(logger: AuditLogger) -> Double {
        let weight = Double(self.weight)
        let height = Double(self.height)
        
        switch self.bodyFatPercentageMethod {
        case .manualEntry:
            let bodyFat = Double(self.bodyFatPercentage) / 100.0
            let lbm = weight * (1 - bodyFat)
            
            return lbm
            
        case .estimate:
            let lbm: Double
            if self.gender == .male {
                lbm = 0.407 * weight + 0.267 * height - 19.2
            } else {
                lbm = 0.252 * weight + 0.473 * height - 48.3
            }
            
            return lbm
            
        case .omit:
            return 0
        }
    }
}
