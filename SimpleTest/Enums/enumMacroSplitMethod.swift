//
//  enumMacroSplitMethod.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

enum enumMacroSplitMethod : Int, CaseIterable {
    case ketogenic = 0
    case lowCarb = 1
    case paleo = 2
    case bulk = 3
    case custom = 4
}

extension enumMacroSplitMethod {
    var displayName: String {
        switch self {
        case .ketogenic: return "Ketogenic"
        case .lowCarb: return "Low Carb"
        case .paleo: return "Paleo"
        case .bulk: return "Bulk"
        case .custom: return "custom"
        }
    }
}
