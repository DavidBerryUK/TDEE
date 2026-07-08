//
//  OptionLength.swift
//  SimpleTest
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
}