import Foundation

/// Represents the user's activity level.
///
/// Five canonical levels, each with a distinct TDEE multiplier
/// (`activityMultiplier`). The legacy near-duplicates — `Light`,
/// `Moderate`, `Active`, `Very Active` — shared multipliers with
/// `lightExercise` / `moderateExercise` / `heavyExercise` / `athlete` and were
/// removed in PA-10; their stored raw values are mapped back to the equivalent
/// level at decode time (see `from(storedRaw:)`).
public enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary = "Sedentary"
    case lightExercise = "Light Exercise"
    case moderateExercise = "Moderate Exercise"
    case heavyExercise = "Heavy Exercise"
    case athlete = "Athlete"

    /// Decodes a stored raw value, mapping the legacy near-duplicate raws removed
    /// in PA-10 (`Light` / `Moderate` / `Active` / `Very Active`) onto their
    /// multiplier-equivalent canonical level — lossless, since the multipliers
    /// match. Current raws decode normally; unknown raws fall back to `.sedentary`.
    static func from(storedRaw: String) -> ActivityLevel {
        switch storedRaw {
        case "Light": return .lightExercise
        case "Moderate": return .moderateExercise
        case "Active": return .heavyExercise
        case "Very Active": return .athlete
        default: return ActivityLevel(rawValue: storedRaw) ?? .sedentary
        }
    }
}

/// Human-readable description for each activity level.
public extension ActivityLevel {
    var description: String {
        switch self {
        case .sedentary: return "Low activity"
        case .lightExercise: return "Light exercise (1-2 days/week)"
        case .moderateExercise: return "Moderate exercise (3-5 days/week)"
        case .heavyExercise: return "Heavy exercise (6-7 days/week)"
        case .athlete: return "Athlete (2x per day)"
        }
    }

    /// Display name for UI (picker, etc.)
    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .lightExercise: return "Light Exercise"
        case .moderateExercise: return "Moderate Exercise"
        case .heavyExercise: return "Heavy Exercise"
        case .athlete: return "Athlete"
        }
    }

    /// The generic activity multiplier (1.2 to 1.9) for this activity level,
    /// applied to both BMR formulas (Mifflin-St Jeor and Katch-McArdle).
    var activityMultiplier: Double {
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
