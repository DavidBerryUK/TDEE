//
//  enumActivityLevel.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

enum enumActivityLevel : Int, CaseIterable {
    case sedentary = 0
    case lightExercise = 1
    case moderateExercise = 2
    case heavyExercise = 3
    case athlete = 4
}

extension enumActivityLevel {
    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary (office job)"
        case .lightExercise: return "Light Exercise (1-2 days)"
        case .moderateExercise: return "Moderate Exercise (3-5 days)"
        case .heavyExercise: return "Heavy Exercise (3-5 days)"
        case .athlete: return "Athlete (2x per day)"
        }
    }
}
