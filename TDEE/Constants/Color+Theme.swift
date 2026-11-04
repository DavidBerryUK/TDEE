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
    /// wheel and selection band beyond its own frame, so clipping keeps them inside the panel. An
    /// optional `width` insets just the wheel into a narrower field, so a multi-wheel group (feet &
    /// inches, stones & pounds) gets one panel per wheel instead of one around the whole group.
    @ViewBuilder
    func pickerPanel(background: Color? = nil, width: CGFloat? = nil) -> some View {
        let panelShape = RoundedRectangle(cornerRadius: 12)
        if let background {
            Group {
                if let width {
                    self.frame(width: width)
                } else {
                    self
                }
            }
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.small)
            .background(background, in: panelShape)
            .clipShape(panelShape)
        } else {
            self
        }
    }

    /// Inset a segmented control into the theme's light picker panel and force its appearance, so its
    /// segments read on a distinct light field instead of washing out on a vivid surface (Orange). Only
    /// picker-themed palettes opt in; every other theme leaves the control bare, exactly as before.
    func segmentDressing() -> some View {
        modifier(SegmentDressingModifier())
    }

    /// Dresses one input section with its own accent: injects `palette.resolved(for:)` for `icon` so the
    /// section's icon chip, text, expanded panel and wheel/segment panel all cohere to its swatch, and
    /// draws the section's own rounded card. No-op when the active palette has no `sectionDressing` — so every
    /// existing theme (and the non-section result/macro cards) render exactly as before.
    ///
    /// The per-section palette is injected into the environment rather than passed in, so the *frozen* picker
    /// views (`UIThemedWheelPicker`, `UISegment*`) pick up the section's dressing from
    /// `@Environment(\.palette)` with no edits to them — the model-layer route the project's picker-freeze
    /// rule requires.
    func sectionDressed(for icon: Icon) -> some View {
        modifier(SectionDressingModifier(icon: icon))
    }

    // MARK: Neon glow — gated on a palette's `glow`, a no-op for every theme that doesn't opt in, so the frozen
    // card/picker views stay untouched and undressed themes render exactly as before.

    /// A theme's neon bloom: a tight bright core inside a wide soft halo, each layer tinted by `color` and
    /// compounding on the previous. `nil` (every theme that doesn't opt in) returns the view unchanged.
    @ViewBuilder
    func neonGlowBloom(_ glow: GlowDressing?, color: Color? = nil) -> some View {
        if let glow {
            let c = color ?? glow.stroke
            self
                .shadow(color: c.opacity(glow.core.opacity), radius: glow.core.radius, x: glow.core.x, y: glow.core.y)
                .shadow(color: c.opacity(glow.halo.opacity), radius: glow.halo.radius, x: glow.halo.x, y: glow.halo.y)
        } else {
            self
        }
    }

    /// A theme's full neon card treatment: a crisp rounded-rect outline in `color`, then the bloom above it.
    /// `color` defaults to the dressing's `stroke`; a dressed section passes its own `sectionAccent`, so the
    /// six-hue rainbow glows per card from a single field. `nil` returns the view unchanged.
    @ViewBuilder
    func neonCard(_ glow: GlowDressing?, color: Color? = nil, radius: CGFloat = 12) -> some View {
        if let glow {
            self
                .overlay(RoundedRectangle(cornerRadius: radius).stroke(color ?? glow.stroke, lineWidth: glow.strokeWidth))
                // The lit-tube core (a bright inner line) when the dressing has one — the part that reads on a
                // light field. No-op for every dressing without a `tubeCore`.
                .neonTube(glow, radius: radius)
                .neonGlowBloom(glow, color: color)
        } else {
            self
        }
    }

    /// A lit-tube core — a thin bright line drawn just *inside* a card's outline, so the border reads as a lit
    /// neon tube rather than a flat stroke. On a *light* field, where an outer halo (a coloured shadow on
    /// near-white) is nearly invisible, this inner line is what registers as "lit". No-op when the dressing has
    /// no `tubeCore` (every theme that doesn't opt in), so undressed cards — and every non-neon theme — draw
    /// their outline exactly as before.
    @ViewBuilder
    func neonTube(_ glow: GlowDressing?, radius: CGFloat = 12) -> some View {
        if let glow, let tube = glow.tubeCore {
            self
                .overlay(
                    RoundedRectangle(cornerRadius: radius - tube.inset)
                        .stroke(tube.color, lineWidth: tube.width)
                        .padding(tube.inset)
                )
        } else {
            self
        }
    }

    /// A neon text bloom for a section heading — a bright core inside a soft halo, tinted by `color`. Fires only
    /// when the dressing has `headingGlow`, and `nil` (every non-neon theme) returns the text unchanged, so body
    /// and value text is never bloomed.
    @ViewBuilder
    func neonHeading(_ glow: GlowDressing?, color: Color? = nil) -> some View {
        if let glow, glow.headingGlow {
            // A scheme can override the heading glow colour (`headingColor`) — light Neon uses a near-white so
            // the titles read as clean lit text instead of a muddy saturated halo. `nil` (every other theme)
            // keeps the per-section hue / house stroke.
            let c = glow.headingColor ?? color ?? glow.stroke
            self
                .shadow(color: c.opacity(0.85), radius: 1.5)
                .shadow(color: c.opacity(0.6), radius: 4)
        } else {
            self
        }
    }
}

/// Injects `palette.resolved(for:)` for one section so the icon, text, wheel and segment panel cohere to its
/// swatch, and draws the section's own rounded card. Identity when the palette has no `sectionDressing`, so
/// undressed themes are byte-for-byte unchanged.
struct SectionDressingModifier: ViewModifier {
    let icon: Icon
    @Environment(\.palette) private var palette

    @ViewBuilder
    func body(content: Content) -> some View {
        // No dressing for this palette: the section keeps the card the container draws around it.
        if palette.sectionDressing != nil {
            let resolved = palette.resolved(for: icon)
            content
                .environment(\.palette, resolved)          // flows to UIIcon + the frozen wheel/segment views
                .foregroundStyle(resolved.text)            // titles/labels with no explicit colour inherit the legible
                .tint(resolved.sectionAccent ?? resolved.primary)   // selection/highlight read in the section's own colour
                .background(resolved.surface, in: RoundedRectangle(cornerRadius: 12))
                // The neon bloom, in the section's own hue (nil for undressed themes → a no-op, so they're untouched).
                .neonCard(resolved.glow, color: resolved.sectionAccent)
        } else {
            content
        }
    }
}

/// Dresses a segmented control like its theme's wheel picker — reusing the palette's picker dressing
/// (`pickerBackground` / `pickerColorScheme`) rather than a parallel set of segment fields, so the
/// control and the wheel stay coherent in one theme.
struct SegmentDressingModifier: ViewModifier {
    @Environment(\.palette) private var palette

    func body(content: Content) -> some View {
        if let background = palette.pickerBackground {
            content
                .environment(\.colorScheme, palette.pickerColorScheme ?? .light)
                .padding(Spacing.small)
                .background(background, in: RoundedRectangle(cornerRadius: 12))
        } else {
            content
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
