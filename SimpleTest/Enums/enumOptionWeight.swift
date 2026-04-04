//
//  enumOptionWeight.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

enum enumOptionWeight : Int, CaseIterable {
    case kilograms = 0
    case pounds = 1
    case stonesAndPounds = 2
}

extension enumOptionWeight {
    var displayName: String {
        switch self {
        case .kilograms: return "Kg"
        case .pounds: return "Pounds"
        case .stonesAndPounds: return "Stones & Pounds"
        }
    }
}
