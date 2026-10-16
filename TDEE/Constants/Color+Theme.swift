//
//  Color+Theme.swift
//  TDEE
//

import SwiftUI

extension EnvironmentValues {
    /// The active theme palette, resolved for the current colour scheme by `ThemedRoot`.
    @Entry var palette: ColorPalette = DefaultThemes.standard.light
}

/// Applies the selected theme to its content: appearance mode, palette and accent tint.
///
/// `preferredColorScheme` is applied outside `PaletteResolver`, so the resolver reads
/// the effective scheme (including the system one in Auto mode).
struct ThemedRoot<Content: View>: View {
    let themeManager: ThemeManager
    @ViewBuilder let content: Content

    var body: some View {
        PaletteResolver(theme: themeManager.theme) { content }
            .environment(themeManager)
            .preferredColorScheme(themeManager.appearance.colorScheme)
    }
}

private struct PaletteResolver<Content: View>: View {
    let theme: Theme
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = theme.palette(for: colorScheme)
        content
            .environment(\.palette, palette)
            .tint(palette.primary)
    }
}

extension View {
    /// Replaces a grouped `List`/`Form`'s system background with the palette's.
    /// Sections set `.listRowBackground(palette.surface)` for their rows.
    func themedGroupedList(_ palette: ColorPalette) -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(palette.background)
    }
}
