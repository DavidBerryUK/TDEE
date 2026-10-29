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
    let inputStyleManager: InputStyleManager
    @ViewBuilder let content: Content

    init(themeManager: ThemeManager, inputStyleManager: InputStyleManager = InputStyleManager(), @ViewBuilder content: () -> Content) {
        self.themeManager = themeManager
        self.inputStyleManager = inputStyleManager
        self.content = content()
    }

    var body: some View {
        PaletteResolver(theme: themeManager.theme) { content }
            .environment(themeManager)
            .environment(inputStyleManager)
            .preferredColorScheme(themeManager.theme.colorScheme ?? themeManager.appearance.colorScheme)
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

    /// Applies a theme's optional toolbar background; keeps the system `.visible` bar when the theme
    /// doesn't override it (the default for every theme that doesn't opt in).
    @ViewBuilder
    func themedToolbarBackground(_ background: Color?) -> some View {
        if let background {
            self.toolbarBackground(background, for: .navigationBar)
        } else {
            self.toolbarBackground(.visible, for: .navigationBar)
        }
    }

    /// Insets a wheel picker into its own rounded-rect panel so it reads as a distinct field. `nil`
    /// (the default for every theme that doesn't opt in) leaves the picker exactly as it was. The
    /// picker's appearance and selection band are handled by `ThemedWheelPicker`, not here.
    ///
    /// The panel is both filled and *clipped* to the same rounded rect: a `UIPickerView` draws its
    /// wheel and selection band beyond its own frame, so clipping keeps them inside the panel.
    @ViewBuilder
    func pickerPanel(background: Color? = nil) -> some View {
        let panelShape = RoundedRectangle(cornerRadius: 12)
        if let background {
            self
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, Spacing.small)
                .background(background, in: panelShape)
                .clipShape(panelShape)
        } else {
            self
        }
    }
}

/// A cluster of toolbar buttons that share one background.
///
/// Neither SwiftUI nor UIKit can tint the system's shared glass behind grouped bar items, so a
/// theme with a `tint` hides that shared background and draws its own tinted Liquid Glass capsule
/// around the cluster. With `tint == nil` the buttons stay ordinary items, grouped by the system.
struct ThemedToolbarCluster<Content: View>: ToolbarContent {
    let placement: ToolbarItemPlacement
    let tint: Color?
    @ViewBuilder let content: Content

    var body: some ToolbarContent {
        if let tint {
            ToolbarItem(placement: placement) {
                HStack(spacing: 0) { content }
                    .labelStyle(.iconOnly)
                    .padding(.horizontal, 4)
                    .glassEffect(.regular.tint(tint), in: .capsule)
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItemGroup(placement: placement) { content }
        }
    }
}
