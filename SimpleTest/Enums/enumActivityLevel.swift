//
//  enumActivityLevel.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

public enum enumActivityLevel : Int, CaseIterable {
    case sedentary = 0,
         lightExercise = 1,
         moderateExercise = 2,
         heavyExercise = 3,
         athlete = 4
}

public extension enumActivityLevel {
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

public extension enumActivityLevel {
    var displayShortName: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .lightExercise: return "Light Exercise"
        case .moderateExercise: return "Moderate Exercise"
        case .heavyExercise: return "Heavy Exercise"
        case .athlete: return "Athlete"
        }
    }
}

public extension enumActivityLevel {
    var KatchMcArdleMultipliers: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .lightExercise:
            return 1.375
        case .moderateExercise:
            return 1.55
        case .heavyExercise:
            return 1.725
        case .athlete:
            return 1.9
        }
    }
}
