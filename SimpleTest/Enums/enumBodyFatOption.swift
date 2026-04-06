//
//  enumBodyFatOption.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

enum enumBodyFatOption : Int ,CaseIterable {
    case omit = 0,
         estimate = 1,
         manualEntry = 2
}

extension enumBodyFatOption {
    var displayName: String {
        switch self {
        case .omit: return "Omit"
        case .estimate: return "Estimate"
        case .manualEntry: return "Manual Entry"
        }
    }
}
