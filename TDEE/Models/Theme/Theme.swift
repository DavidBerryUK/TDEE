//
//  Theme.swift
//  TDEE
//

import SwiftUI

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

    /// `editText`, `highlight` and `selection` default to `primary`; Default overrides them
    /// to keep the app's original red, teal and green.
    init(
        primary: Color, secondary: Color, background: Color, surface: Color,
        text: Color, textSecondary: Color, border: Color,
        macroProtein: Color, macroCarbs: Color, macroFat: Color,
        editText: Color? = nil, highlight: Color? = nil, selection: Color? = nil
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
    }
}

/// A named theme with a palette for each colour scheme.
struct Theme: Identifiable {
    let id: ThemeID
    let name: String
    let description: String
    let light: ColorPalette
    let dark: ColorPalette

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
}
