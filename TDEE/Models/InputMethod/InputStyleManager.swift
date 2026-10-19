//
//  InputStyleManager.swift
//  TDEE
//
//  Story 023 (Input Method) — Task 1: the per-input Classic/New preference store.
//

import Foundation
import Observation

/// The input style an input can be presented in.
///
/// `.classic` is the control the app uses today; `.new` is that input's redesigned control, built
/// input-by-input in later tasks of this story.
enum InputStyle: String, CaseIterable, Codable, Identifiable {
    case classic
    case `new`

    var id: String { rawValue }

    var label: String {
        switch self {
        case .classic: "Classic"
        case .new: "New"
        }
    }
}

/// The sections the input list is grouped into, mirroring the main screen.
enum InputSection: String, CaseIterable, Identifiable {
    case personal = "Personal"
    case activity = "Activity"
    case bodyFat = "Body Fat"
    case calories = "Calories"
    case macros = "Macros"

    var id: String { rawValue }
    var title: String { rawValue }
}

/// Every input the app takes; each carries its own Classic/New preference.
enum InputID: String, CaseIterable, Hashable, Codable, Identifiable {
    case gender
    case age
    case weightUom
    case weight
    case heightUom
    case height
    case activityLevel
    case bodyFatMethod
    case bodyFatPercentage
    case calorieAdjustmentMethod
    case calorieAdjustment
    case macroSplitMethod
    case macroMix

    var id: String { rawValue }

    var label: String {
        switch self {
        case .gender: "Gender"
        case .age: "Age"
        case .weightUom: "Weight Units"
        case .weight: "Weight"
        case .heightUom: "Height Units"
        case .height: "Height"
        case .activityLevel: "Activity Level"
        case .bodyFatMethod: "Body Fat Method"
        case .bodyFatPercentage: "Body Fat %"
        case .calorieAdjustmentMethod: "Calorie Adjustment Method"
        case .calorieAdjustment: "Calorie Adjustment"
        case .macroSplitMethod: "Macro Split Method"
        case .macroMix: "Macro Mix"
        }
    }

    var section: InputSection {
        switch self {
        case .gender, .age, .weightUom, .weight, .heightUom, .height: .personal
        case .activityLevel: .activity
        case .bodyFatMethod, .bodyFatPercentage: .bodyFat
        case .calorieAdjustmentMethod, .calorieAdjustment: .calories
        case .macroSplitMethod, .macroMix: .macros
        }
    }
}

/// Holds the user's per-input Classic/New preference, persisted to `UserDefaults`.
///
/// Mirrors `ThemeManager`: a global `@Observable` store injected through the environment. Any input
/// with no stored preference falls back to `.classic` (today's behaviour — Decision 5).
@Observable
final class InputStyleManager {

    enum Keys {
        static let styles = "input.style.preferences"
    }

    @ObservationIgnored private let defaults: UserDefaults

    /// Per-input style. An input absent here is treated as `.classic`.
    var styles: [InputID: InputStyle] = [:]

    /// The style for an input, defaulting to `.classic` when none is stored.
    func style(for input: InputID) -> InputStyle {
        styles[input] ?? .classic
    }

    /// Set and persist an input's style.
    func setStyle(_ style: InputStyle, for input: InputID) {
        styles[input] = style
        persist()
    }

    /// Return every input to `.classic` (clears stored preferences).
    func resetToClassic() {
        styles.removeAll()
        persist()
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.styles = Self.load(from: defaults)
    }

    private static func load(from defaults: UserDefaults) -> [InputID: InputStyle] {
        guard let stored = defaults.object(forKey: Keys.styles) as? [String: String] else { return [:] }
        var result: [InputID: InputStyle] = [:]
        for (key, value) in stored {
            guard let id = InputID(rawValue: key), let style = InputStyle(rawValue: value) else { continue }
            result[id] = style
        }
        return result
    }

    private func persist() {
        // `UserDefaults` stores only plist objects, so both keys and values must be `String` —
        // mapping values alone leaves `InputID` enum keys and throws at `set(_:)`.
        let plist: [String: String] = Dictionary(
            styles.map { ($0.key.rawValue, $0.value.rawValue) },
            uniquingKeysWith: { first, _ in first }
        )
        defaults.set(plist, forKey: Keys.styles)
    }
}
