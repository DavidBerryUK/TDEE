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
