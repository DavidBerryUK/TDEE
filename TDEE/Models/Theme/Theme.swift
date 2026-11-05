//
//  Theme.swift
//  TDEE
//

import SwiftUI
import Foundation

/// The colour roles every view draws from. See documentation/stories/story-018-themes/palettes.md.
struct ColorPalette {
    let primary: Color
    let secondary: Color
    let background: Color
    let surface: Color
    let text: Color
    let textSecondary: Color
    let border: Color
    let macroProtein: Color
    let macroCarbs: Color
    let macroFat: Color
    /// Text of the field being edited (an expanded section's value).
    let editText: Color
    /// Outline of highlighted result cards (e.g. daily/weekly calories).
    let highlight: Color
    /// Marks the selected item in a list (e.g. the active macro preset).
    let selection: Color

    /// Optional navigation-bar override. `nil` (the default) keeps the app's system bar.
    let toolbar: Toolbar?
    /// Optional per-icon colour for `UIIcon`. `nil` keeps each icon's built-in catalog colour;
    /// a present entry (the map may be partial) wins for that icon.
    let iconColors: [Icon: Color]?

    /// Background of a section's *expanded* content area, drawn beneath the editor while the section
    /// is open. `nil` (the default) leaves the content on the section's `surface`; a value tints just
    /// the expanded region, so it reads as a distinct panel while the header stays on `surface`.
    let expandedContentBackground: Color?

    /// The wheel picker's own panel background, drawn as a rounded rect *around* the picker so its
    /// highlighted row reads against a distinct field. `nil` (the default) leaves the picker on the
    /// section surface; a value insets just the picker into that tint while the picker's label (e.g.
    /// "age in years") stays outside the rect, on the section content.
    let pickerBackground: Color?

    /// The wheel picker's appearance override, so its rows read on a light panel. The `.wheel` style
    /// is a `UIPickerView` that draws its rows in the system label colour and ignores `foregroundStyle`,
    /// so on a light panel the digits stay light and wash out; forcing `.light` here makes the rows
    /// render dark. `nil` (the default) keeps the picker on the app's scheme, correct on every other
    /// theme's dark surface.
    let pickerColorScheme: ColorScheme?

    /// The wheel picker's fixed panel width, so a theme can inset each wheel into a narrower field.
    /// `nil` (the default) leaves the panel at the wheel's natural width.
    let pickerPanelWidth: CGFloat?

    /// The wheel picker's unit-caption x-offset (the "cm"/"inches"/"feet"/"inches" label). `nil`
    /// (the default) keeps each wheel's own caption position; a value shifts the caption so it can
    /// sit outside a narrowed panel.
    let pickerLabelOffsetX: CGFloat?

    /// The feet wheel's ("feet") caption x-offset within a compound unit (feet & inches). Kept separate
    /// from `pickerLabelOffsetX` because the same centre-offset can't give "feet" (a short label) and
    /// "inches" (a longer one) equal gaps from their panels. `nil` (the default) falls back to
    /// `pickerLabelOffsetX`, then the wheel's own position, so a theme that doesn't set it is unchanged.
    let pickerFeetLabelOffsetX: CGFloat?

    /// The feet-&-inches wheel's ("inches" caption) x-offset within a compound unit. See
    /// `pickerFeetLabelOffsetX`; `nil` (the default) falls back to `pickerLabelOffsetX`.
    let pickerFeetInchesLabelOffsetX: CGFloat?

    /// The gap between the two wheels of a compound unit (feet & inches, stones & pounds), so a unit
    /// caption can sit *between* them. `nil` (the default) uses the group's natural spacing.
    let pickerWheelSpacing: CGFloat?

    /// This palette's own per-section accent — the swatch `UIIcon` colours its chip with, read *first*
    /// before the theme-wide `iconColors`. Set by `resolved(for:)`; `nil` on a theme's base palette (so the
    /// chip falls back to `iconColors`, then the built-in catalog colour).
    let sectionAccent: Color?

    /// The per-section dressing the theme adopts (`SectionDressing`); `nil` means no per-section dressing,
    /// so every existing theme is untouched. `resolved(for:)` consumes it to produce a per-section palette
    /// and clears it (to `nil`) on the result, so resolution never recurses.
    let sectionDressing: SectionDressing?

    /// The theme's neon bloom — a crisp rounded-rect outline plus a layered-shadow glow on every card, and
    /// (optionally) glowing section headings. `nil` (the default) means no glow, so every theme that doesn't
    /// opt in renders byte-for-byte unchanged and the frozen card/picker views are never edited — the opt-in
    /// discipline `PickerDressing`/`SectionDressing` use. The per-card glow *colour* falls out of the existing
    /// resolution (`resolved.sectionAccent ?? glow.stroke`), so a multi-hue glow needs no per-card field.
    /// `resolved(for:)` propagates it through *both* branches, or a dressed section would resolve to `glow ==
    /// nil` and glow nothing.
    let glow: GlowDressing?

    /// Whether the theme dresses the wheel picker — a panel or a forced appearance. A parent shows the
    /// themed wheel (`UIWheelXxxThemed`) when this is true and the plain wheel (`UIWheelXxxPlain`)
    /// otherwise; every theme that doesn't opt in leaves both picker fields `nil`, so its wheels stay
    /// plain.
    var isPickerThemed: Bool {
        pickerBackground != nil || pickerColorScheme != nil
    }

    /// This palette with the per-section fields for `icon` substituted, so a section's icon chip, text,
    /// expanded panel and wheel/segment panel all cohere to its swatch — without editing the frozen picker
    /// views (they read the resulting fields from the injected `@Environment(\.palette)`).
    ///
    /// Returns `self` unchanged when there is no dressing for this icon (or none at all), so a non-dressed
    /// palette is a no-op and the existing themes render exactly as before. The result always clears
    /// `sectionDressing` (to `nil`) so resolution never recurses.
    func resolved(for icon: Icon) -> ColorPalette {
        guard let dressing = sectionDressing, let accent = dressing.accents[icon] else {
            return self
        }
        switch accent.mode {
        case .bold:
            // Fill the section with the swatch; text is the legible colour for that swatch (white on the
            // dark swatches, near-black on yellow/orange). The wheel/segment panel is a light tint of the
            // swatch with forced-light digits, exactly the Orange theme's treatment.
            let onText = accent.onText
            return ColorPalette(
                primary: onText,
                secondary: secondary,
                background: background,
                surface: accent.swatch,
                text: onText,
                textSecondary: onText.opacity(0.75),
                border: border,
                macroProtein: macroProtein,
                macroCarbs: macroCarbs,
                macroFat: macroFat,
                editText: onText,
                highlight: onText,
                selection: onText,
                toolbar: toolbar,
                iconColors: iconColors,
                expandedContentBackground: accent.swatch,
                pickerDressing: .panel(background: accent.panelBackground, appearance: .light, width: 96),
                sectionAccent: accent.swatch,
                sectionDressing: nil,
                glow: glow
            )
        case .subtle:
            // A light tint of the swatch on the field; text and selection stay the base palette's. Wheels
            // stay plain (no per-section dressing) — the subtle variation keeps the rainbow on the card +
            // the solid icon chip only.
            return ColorPalette(
                primary: primary,
                secondary: secondary,
                background: background,
                surface: accent.swatch.opacity(dressing.subtleIntensity),
                text: text,
                textSecondary: textSecondary,
                border: border,
                macroProtein: macroProtein,
                macroCarbs: macroCarbs,
                macroFat: macroFat,
                toolbar: toolbar,
                iconColors: iconColors,
                expandedContentBackground: accent.swatch.opacity(min(dressing.subtleIntensity + 0.08, 0.5)),
                pickerDressing: nil,
                sectionAccent: accent.swatch,
                sectionDressing: nil,
                glow: glow
            )
        }
    }

    /// How a theme overrides the navigation bar. A `nil` `background` keeps
    /// `.toolbarBackground(.visible, for: .navigationBar)`.
    struct Toolbar {
        /// The bar behind the menu buttons; `nil` keeps the system `.visible` bar.
        var background: Color?
        /// The chip the system draws behind the grouped menu buttons; `nil` keeps the system grey.
        var itemBackground: Color?
        init(background: Color? = nil, itemBackground: Color? = nil) {
            self.background = background
            self.itemBackground = itemBackground
        }
    }

    /// `editText`, `highlight` and `selection` default to `primary`; Default overrides them
    /// to keep the app's original red, teal and green. `toolbar`/`iconColors`/`expandedContentBackground`
    /// default to `nil`, so every theme keeps today's system bar, icon colours and content background
    /// unless it opts in. The picker's seven fields come from one adopted `pickerDressing` (a
    /// `PickerDressing`; `nil` = `.plain`/undressed), so a theme dresses its wheels by adopting a
    /// dressing rather than setting seven numbers. The fields stay stored on the palette — the frozen
    /// picker views read them by name — so the dressing is the model-layer generalisation and the views
    /// stay untouched.
    init(
        primary: Color, secondary: Color, background: Color, surface: Color,
        text: Color, textSecondary: Color, border: Color,
        macroProtein: Color, macroCarbs: Color, macroFat: Color,
        editText: Color? = nil, highlight: Color? = nil, selection: Color? = nil,
        toolbar: Toolbar? = nil, iconColors: [Icon: Color]? = nil,
        expandedContentBackground: Color? = nil,
        pickerDressing: PickerDressing? = nil,
        sectionAccent: Color? = nil, sectionDressing: SectionDressing? = nil,
        glow: GlowDressing? = nil
    ) {
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.surface = surface
        self.text = text
        self.textSecondary = textSecondary
        self.border = border
        self.macroProtein = macroProtein
        self.macroCarbs = macroCarbs
        self.macroFat = macroFat
        self.editText = editText ?? primary
        self.highlight = highlight ?? primary
        self.selection = selection ?? primary
        self.toolbar = toolbar
        self.iconColors = iconColors
        self.expandedContentBackground = expandedContentBackground
        // The picker's seven fields come from one adopted `PickerDressing`, expanded here so the stored
        // fields — which the frozen picker views read by name — keep their names; `nil` is `.plain`
        // (undressed, the app's original wheel).
        let dressing = pickerDressing ?? .plain
        self.pickerBackground = dressing.background
        self.pickerColorScheme = dressing.colorScheme
        self.pickerPanelWidth = dressing.panelWidth
        self.pickerLabelOffsetX = dressing.labelOffsetX
        self.pickerFeetLabelOffsetX = dressing.feetLabelOffsetX
        self.pickerFeetInchesLabelOffsetX = dressing.feetInchesLabelOffsetX
        self.pickerWheelSpacing = dressing.wheelSpacing
        self.sectionAccent = sectionAccent
        self.sectionDressing = sectionDressing
        self.glow = glow
    }
}

/// A named theme with a palette for each colour scheme.
struct Theme: Identifiable {
    let id: ThemeID
    let name: String
    let description: String
    let light: ColorPalette
    let dark: ColorPalette
    /// Pins the app to one colour scheme, overriding the Appearance setting. For themes whose
    /// palette only works one way (Orange's black field needs dark-mode system text, e.g. nav
    /// titles and list headers); `nil` (the default) follows the user's Appearance choice.
    var colorScheme: ColorScheme? = nil

    /// The theme's typeface. `nil` (the default) keeps the system font, so every existing theme is
    /// byte-for-byte unchanged; a present typeface (e.g. `ThemeTypography.sourceSans3`) is injected by
    /// `PaletteResolver` and resolved by the central text components.
    var typeface: ThemeTypography? = nil

    func palette(for colorScheme: ColorScheme) -> ColorPalette {
        colorScheme == .dark ? dark : light
    }
}

extension Color {
    /// Creates a colour from a `#RRGGBB` hex string. Invalid input gives black.
    init(hex: String) {
        let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt32(digits, radix: 16) ?? 0
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    /// White or near-black, whichever has the better contrast against a solid `#hex` swatch — the per-section
    /// text for the bold mode (a rainbow forces a per-section text colour; see `SectionAccent.onText`).
    ///
    /// `Color` exposes no RGB, so the decision is computed from the hex string: the swatch's relative
    /// luminance decides which of white / near-black contrasts better.
    static func legibleText(forHex hex: String) -> Color {
        let luminance = relativeLuminance(rgbFromHex(hex))
        let whiteContrast = (1.0 + 0.05) / (luminance + 0.05)
        let blackContrast = (luminance + 0.05) / 0.05
        return blackContrast > whiteContrast ? Color(hex: "#141414") : .white
    }

    /// A light tint of a `#hex` swatch, blended `ratio` toward white — used as a bold section's wheel/segment
    /// panel so the forced-light digits read while the panel stays in the section's colour family.
    static func lightTint(forHex hex: String, ratio: Double = 0.82) -> Color {
        let rgb = rgbFromHex(hex)
        func lighten(_ channel: Double) -> Double { channel + (1 - channel) * ratio }
        return Color(
            .sRGB,
            red: lighten(rgb.0),
            green: lighten(rgb.1),
            blue: lighten(rgb.2)
        )
    }

    /// The normalised sRGB channels (each 0…1) of a `#RRGGBB` string; invalid input gives black.
    private static func rgbFromHex(_ hex: String) -> (Double, Double, Double) {
        let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt32(digits, radix: 16) ?? 0
        return (
            Double((value >> 16) & 0xFF) / 255,
            Double((value >> 8) & 0xFF) / 255,
            Double(value & 0xFF) / 255
        )
    }

    /// WCAG relative luminance of an sRGB colour, linearising each channel first.
    private static func relativeLuminance(_ rgb: (Double, Double, Double)) -> Double {
        func linear(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(rgb.0) + 0.7152 * linear(rgb.1) + 0.0722 * linear(rgb.2)
    }
}
