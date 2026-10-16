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
}