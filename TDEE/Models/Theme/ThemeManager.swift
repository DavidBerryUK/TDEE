//
//  ThemeManager.swift
//  TDEE
//

import Foundation
import Observation

/// Holds the selected theme and appearance mode, persisted to `UserDefaults`.
///
/// Unknown or missing stored values fall back to `.standard` and `.auto`.
@Observable
final class ThemeManager {

    enum Keys {
        static let themeID = "theme.id"
        static let appearance = "theme.appearance"
    }

    @ObservationIgnored private let defaults: UserDefaults

    var themeID: ThemeID {
        didSet { defaults.set(themeID.rawValue, forKey: Keys.themeID) }
    }

    var appearance: AppearanceMode {
        didSet { defaults.set(appearance.rawValue, forKey: Keys.appearance) }
    }

    var theme: Theme { DefaultThemes.theme(for: themeID) }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.themeID = defaults.string(forKey: Keys.themeID).flatMap(ThemeID.init(rawValue:)) ?? .standard
        self.appearance = defaults.string(forKey: Keys.appearance).flatMap(AppearanceMode.init(rawValue:)) ?? .auto
    }
}
