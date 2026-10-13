//
//  CalorieAdjustmentMethod.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

/// Represents the method for adjusting daily calorie intake.
public enum CalorieAdjustmentMethod : Int, CaseIterable, Sendable {
    case cut = 0,
         maintain = 1,
         bulk = 2
}

extension CalorieAdjustmentMethod {
    /// The display name for this adjustment method.
    var displayName: String {
        switch self {
        case .cut: return "Cut"
        case .maintain: return "Maintain"
        case .bulk: return "Bulk"
        }
    }

    /// The section title for this adjustment method.
    var sectionTitle: String {
        switch self {
        case .cut: return "Daily Deficit"
        case .maintain: return "Adjust Daily Calories"
        case .bulk: return "Daily Surplus"
        }
    }

    /// The prefix to show before the adjustment value.
    var adjustmentPrefix: String {
        switch self {
        case .cut: return "-"
        case .maintain: return ""
        case .bulk: return "+"
        }
    }
}
