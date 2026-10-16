//
//  Gender.swift
//  TDEE
//
//  Created by David Berry on 03/04/2026.
//

/// Represents the user's gender for calculation purposes.
public enum Gender : Int, CaseIterable, Sendable {
    case male = 0,
         female = 1
}

extension Gender {
    /// The display name for this gender.
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}
