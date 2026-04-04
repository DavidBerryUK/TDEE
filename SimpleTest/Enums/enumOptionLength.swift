//
//  enumOptionLength.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

enum enumOptionLength : Int, CaseIterable {
    case centimeters = 0
    case inches = 1
    case feetAndInches = 2
}

extension enumOptionLength {
    var displayName: String {
        switch self {
        case .centimeters: return "Cm"
        case .inches: return "Inches"
        case .feetAndInches: return "Feet & Inches"
        }
    }
}
