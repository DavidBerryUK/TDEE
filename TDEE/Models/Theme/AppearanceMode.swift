//
//  AppearanceMode.swift
//  TDEE
//

import SwiftUI

/// The user's light/dark preference, applied with `.preferredColorScheme`.
enum AppearanceMode: String, CaseIterable, Identifiable {
    case auto
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .auto: "Auto"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    /// `nil` lets the system decide (Auto).
    var colorScheme: ColorScheme? {
        switch self {
        case .auto: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
