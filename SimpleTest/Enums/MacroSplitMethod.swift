//
//  MacroSplitMethod.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

/// Represents a macro split dietary method.
public enum MacroSplitMethod : Int, CaseIterable {
    case ketogenic = 0,
         lowCarb = 1,
         paleo = 2,
         bulk = 3,
         custom = 4
}

extension MacroSplitMethod {
    /// The display name for this macro split method.
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
