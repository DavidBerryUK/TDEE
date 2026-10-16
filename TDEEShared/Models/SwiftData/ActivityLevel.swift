import Foundation

/// Represents the user's activity level (sedentary, light, moderate, active, very active).
public enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary = "Sedentary"
    case light = "Light"
    case moderate = "Moderate"
    case active = "Active"
    case veryActive = "Very Active"

    // Additional cases for Katch-McArdle calculations
    case lightExercise = "Light Exercise"
    case moderateExercise = "Moderate Exercise"
    case heavyExercise = "Heavy Exercise"
    case athlete = "Athlete"
}

/// Human-readable description for each activity level.
public extension ActivityLevel {
    var description: String {
        switch self {
        case .sedentary: return "Low activity"
        case .light: return "Moderate activity"
        case .moderate: return "Moderate activity"
        case .active: return "High activity"
        case .veryActive: return "Very high activity"
        case .lightExercise: return "Light exercise (1-2 days/week)"
        case .moderateExercise: return "Moderate exercise (3-5 days/week)"
        case .heavyExercise: return "Heavy exercise (3-5 days/week)"
        case .athlete: return "Athlete (2x per day)"
        }
    }

    /// Display name for UI (picker, etc.)
    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        case .lightExercise: return "Light Exercise"
        case .moderateExercise: return "Moderate Exercise"
        case .heavyExercise: return "Heavy Exercise"
        case .athlete: return "Athlete"
        }
    }

    /// Short display name for UI
    var displayShortName: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        case .lightExercise: return "Light Exercise"
        case .moderateExercise: return "Moderate Exercise"
        case .heavyExercise: return "Heavy Exercise"
        case .athlete: return "Athlete"
        }
    }

    /// The Katch-McArdle multiplier for this activity level.
    var KatchMcArdleMultipliers: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .light, .lightExercise:
            return 1.375
        case .moderate, .moderateExercise:
            return 1.55
        case .active, .heavyExercise:
            return 1.725
        case .veryActive, .athlete:
            return 1.9
        }
    }
}
