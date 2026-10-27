//
//  OptionWeight.swift
//  TDEE
//
//  Created by David Berry on 03/04/2026.
//

public enum OptionWeight : Int, CaseIterable {
    case kilograms = 0,
         pounds = 1,
         stonesAndPounds = 2
}

extension OptionWeight {
    var displayName: String {
        switch self {
        case .kilograms: return "Kg"
        case .pounds: return "Pounds"
        case .stonesAndPounds: return "Stones & Pounds"
        }
    }

    /// The full unit name shown on the unit-switcher button (e.g. "Kilograms"), paired with a selector
    /// chevron so the control reads as a value picker. Kept separate from `displayName` because that
    /// short form ("Kg") also labels the accessibility-size segmented control, which can't carry the
    /// spelled-out name in every segment.
    var fullName: String {
        switch self {
        case .kilograms: return "Kilograms"
        case .pounds: return "Pounds"
        case .stonesAndPounds: return "Stones & Pounds"
        }
    }
}