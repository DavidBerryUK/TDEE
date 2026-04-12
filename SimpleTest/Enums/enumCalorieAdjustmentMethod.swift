//
//  enumCalorieAdjustmentMethod.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

enum enumCalorieAdjustmentMethod : Int, CaseIterable {
    case cut = 0,
         maintain = 1,
         bulk = 2
}

extension enumCalorieAdjustmentMethod {
    var displayName: String {
        switch self {
        case .cut: return "Cut"
        case .maintain: return "Maintain"
        case .bulk: return "Bulk"
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .cut: return "Daily Deficit"
        case .maintain: return "Adjust Daily Calories"
        case .bulk: return "Daily Surplus"
        }
    }
    
    var adjustmentPrefix: String {
        switch self {
        case .cut: return "-"
        case .maintain: return ""
        case .bulk: return "+"
        }
    }
}
