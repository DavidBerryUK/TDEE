//
//  CalculateKatchMcArdle.swift
//  SimpleTest
//
//  Created by David Berry on 30/06/2026.
//

extension ProfileViewModel {
    func adjustCalories(base: Double, logger: AuditLogger) -> Double {
        switch self.calorieAdjustmentMethod {
        case .maintain:
            return max( 0, base)
        case .bulk:
            return max( 0, base + Double(self.calorieAdjustment))
        case .cut:
            return max( 0, base - Double(self.calorieAdjustment))
        }
    }
}
