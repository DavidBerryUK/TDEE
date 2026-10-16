//
//  WatchPalette.swift
//  TDEE Watch
//

import SwiftUI

/// The watch app's one fixed palette. Themes are iPhone-only: the watch never reads the
/// selected theme or appearance mode. Values match the iPhone Default theme in dark mode.
enum WatchPalette {
    static let macroProtein = Color.red.opacity(0.85)
    static let macroCarbs = Color.blue
    static let macroFat = Color.mint
    /// Marks the selected macro preset.
    static let selection = Color.green
    static let textSecondary = Color.secondary
    /// Marks inputs a new profile still needs.
    static let attention = Color.orange
}
