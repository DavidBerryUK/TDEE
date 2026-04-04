//
//  enumGender.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

enum enumGender : Int, CaseIterable {
    case male = 0
    case female = 1
}

extension enumGender {
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}
