//
//  SectionDressing.swift
//  TDEE
//

import SwiftUI

/// How a theme dresses its input sections — full-saturation fill (bold) or a light tint (subtle).
enum SectionAccentMode {
    case bold
    case subtle
}

/// One input section's accent: the swatch plus how strongly it's applied.
///
/// Keyed by `Icon` in a `SectionDressing`, the way a `PickerDressing` is adopted by a `ColorPalette`. The
/// hex is kept (not just the `Color`) so the legibility helpers can compute from it — `Color` exposes no RGB.
struct SectionAccent: Equatable {
    /// The swatch's `#RRGGBB` value.
    let hex: String
    /// How strongly the swatch is applied to the section.
    let mode: SectionAccentMode

    /// The solid swatch colour.
    var swatch: Color { Color(hex: hex) }

    /// White or near-black, whichever contrasts with the swatch — the per-section text for the bold mode.
    /// A rainbow forces a per-section text colour: dark swatches take white, light ones (yellow, orange) take
    /// near-black.
    var onText: Color { Color.legibleText(forHex: hex) }

    /// The section's wheel/segment panel colour for bold mode — a light tint of the swatch so the forced-light
    /// digits read while the panel stays in the section's colour family (the Orange theme's light-coral panel).
    var panelBackground: Color { Color.lightTint(forHex: hex) }
}

/// How a theme dresses its input sections — a `[Icon: SectionAccent]` map the theme adopts, mirroring
/// `PickerDressing`. `nil` on a `ColorPalette` means "no per-section dressing" (every theme that doesn't opt
/// in), so existing themes are untouched. A theme adopts a dressing via `ColorPalette(sectionDressing:)`;
/// `ColorPalette.resolved(for:)` expands one entry into a per-section palette.
struct SectionDressing: Equatable {

    /// The dressed input sections, keyed by `Icon` (only input-section icons are set).
    let accents: [Icon: SectionAccent]
    /// The subtle mode's card-fill strength — a tint of the swatch over the field (a value in 0…1).
    var subtleIntensity: Double

    init(accents: [Icon: SectionAccent], subtleIntensity: Double = 0.14) {
        self.accents = accents
        self.subtleIntensity = subtleIntensity
    }

    var isEmpty: Bool { accents.isEmpty }

    /// The input sections in display order — the order `MainSectionProfileInput` lays them out. Used to
    /// render the rainbow chip and to build the named dressings so every input section is covered.
    static let inputSections: [Icon] = [.gender, .age, .height, .weight, .activityLevel, .bodyFat]

    /// The LGBTQ+ rainbow: each of the six input sections a distinct swatch, in `inputSections` order.
    static func pride(_ mode: SectionAccentMode) -> SectionDressing {
        // Display order → swatch. Kept as a table so `inputSections` and the colours can't drift apart.
        let swatches: [Icon: String] = [
            .gender:        "#E70000", // red
            .age:           "#FF8C00", // orange
            .height:        "#FFEE00", // yellow
            .weight:        "#00811F", // green
            .activityLevel: "#0044FF", // blue
            .bodyFat:       "#760089", // purple
        ]
        let accents = inputSections.reduce(into: [Icon: SectionAccent]()) { accumulation, icon in
            if let hex = swatches[icon] {
                accumulation[icon] = SectionAccent(hex: hex, mode: mode)
            }
        }
        return SectionDressing(accents: accents)
    }

    /// The Neon rainbow: the same six electric hues as a `[Icon: String]` table over `inputSections`, in one
    /// source so both neon schemes share a single rainbow — mirroring `pride(_)`. Neon uses `.subtle` for
    /// *both* schemes: a faint tint of the hue with a crisp neon outline and a glow — the restrained "neon card"
    /// look that matches the result/macro boxes — on a near-black field in dark and a near-white one in light.
    /// `subtleIntensity` tunes the tint (0.1 matches the macro cards exactly); `.bold` (a solid hue fill, white/
    /// near-black text via `legibleText`) is still available for Pride-dark but no longer used by Neon.
    static func neon(_ mode: SectionAccentMode, subtleIntensity: Double = 0.14) -> SectionDressing {
        // Display order → swatch. Kept as a table so `inputSections` and the colours can't drift apart.
        let swatches: [Icon: String] = [
            .gender:        "#1E5CFF", // electric blue
            .age:           "#E6007A", // hot magenta
            .height:        "#F0C000", // neon yellow
            .weight:        "#00B85C", // neon green
            .activityLevel: "#E65100", // neon orange
            .bodyFat:       "#9B2BFF", // electric violet
        ]
        let accents = inputSections.reduce(into: [Icon: SectionAccent]()) { accumulation, icon in
            if let hex = swatches[icon] {
                accumulation[icon] = SectionAccent(hex: hex, mode: mode)
            }
        }
        return SectionDressing(accents: accents, subtleIntensity: subtleIntensity)
    }

    /// A warm *sunset* gradient across the six input sections, top to bottom — a gold → amber → orange →
    /// pumpkin → red → deep-red progression over `inputSections`, so a dressed theme reads as a warm gradient
    /// down its input card rather than a full-saturation rainbow. Kept as a table over `inputSections`,
    /// mirroring `pride(_)`/`neon(_)`, so the order and the hues can't drift apart. Sunflower adopts it in
    /// `.bold` on its dark scheme: each section filled with its hue and text auto-legible
    /// (`SectionAccent.onText` — near-black on the bright top hues, white on the deep bottom ones).
    static func warmGradient(_ mode: SectionAccentMode) -> SectionDressing {
        // Display order → warm hue, a sunset progression. Kept as a table so `inputSections` and the
        // colours can't drift apart.
        let swatches: [Icon: String] = [
            .gender:        "#FFC107", // amber gold
            .age:           "#FF9800", // orange
            .height:        "#FB8C00", // dark orange
            .weight:        "#F4511E", // deep orange / pumpkin
            .activityLevel: "#E53935", // warm red
            .bodyFat:       "#B71C1C", // deep red
        ]
        let accents = inputSections.reduce(into: [Icon: SectionAccent]()) { accumulation, icon in
            if let hex = swatches[icon] {
                accumulation[icon] = SectionAccent(hex: hex, mode: mode)
            }
        }
        return SectionDressing(accents: accents)
    }
}
