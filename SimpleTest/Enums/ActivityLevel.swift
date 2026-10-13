//
//  ActivityLevel.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

/// Represents the user's activity level for TDEE calculation.
public enum ActivityLevel : Int, CaseIterable, Sendable {
    case sedentary = 0,
         lightExercise = 1,
         moderateExercise = 2,
         heavyExercise = 3,
         athlete = 4
}

extension ActivityLevel {
    /// The display name for this activity level.
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

extension ActivityLevel {
    /// A short display name for this activity level.
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

extension ActivityLevel {
    /// The Katch-McArdle multiplier for this activity level.
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
