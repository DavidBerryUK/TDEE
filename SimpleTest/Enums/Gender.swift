//
//  Gender.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

public enum Gender : Int, CaseIterable {
    case male = 0,
         female = 1
}

extension Gender {
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}