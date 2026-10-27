//
//  OptionLength.swift
//  TDEE
//
//  Created by David Berry on 03/04/2026.
//

public enum OptionLength : Int, CaseIterable {
    case centimeters = 0,
         inches = 1,
         feetAndInches = 2
}

extension OptionLength {
    var displayName: String {
        switch self {
        case .centimeters: return "Cm"
        case .inches: return "Inches"
        case .feetAndInches: return "Feet & Inches"
        }
    }

    /// The full unit name shown on the unit-switcher button (e.g. "Centimeters"), paired with a selector
    /// chevron so the control reads as a value picker. Kept separate from `displayName` because that
    /// short form ("Cm") also labels the accessibility-size segmented control, which can't carry the
    /// spelled-out name in every segment.
    var fullName: String {
        switch self {
        case .centimeters: return "Centimeters"
        case .inches: return "Inches"
        case .feetAndInches: return "Feet & Inches"
        }
    }
}