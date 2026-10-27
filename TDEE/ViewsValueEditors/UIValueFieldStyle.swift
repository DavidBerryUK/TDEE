//
//  UIValueFieldStyle.swift
//  TDEE
//
//  Story 023 (look/feel pass) — the one styling shared by every New numeric value entry.
//

import SwiftUI
import UIKit

/// Styling for a New numeric value entry (age / weight / height / body-fat % / calorie adjustment).
///
/// One canonical box width (`fieldWidth`) and one suffix reservation keep every value box the same
/// size; the calling section right-aligns the box so all boxes share a right edge. A UoM that renders
/// two fields (stones & pounds, feet & inches) keeps each sub-field at `fieldWidth` and lets the group
/// extend *left* from that shared right edge — the box never grows right or changes size when the unit
/// changes, only the number of sub-fields to its left.
struct UIValueFieldStyle: ViewModifier {

    /// The in-field unit suffix (`kg`, `cm`, `yrs`, `kCals`, …). An empty suffix renders no overlay and
    /// reserves no space; every production entry carries a unit today.
    let suffix: String
    /// Trailing space reserved, at the *default* type size, so a typed number never slides under the
    /// in-field suffix. Sized for the short suffixes (`kg`/`cm`/`in`/`lb`/`st`/`ft`/`%`/`yrs`), widened
    /// for `kCals`. This is the *base*: the live reserve is `suffixReserve × reserveScale`, scaled with the
    /// user's Large-Text setting (below). An empty suffix reserves nothing and shows no overlay.
    var suffixReserve: CGFloat = 30
    /// The keyboard for the field; `.numberPad` by default, `.decimalPad` for body-fat %.
    var keyboardType: UIKeyboardType = .numberPad
    /// Full width at accessibility sizes, a fixed `fieldWidth` otherwise.
    let fullWidth: Bool

    /// Multiplies the base `suffixReserve` by the user's Large-Text scale. `UITextPickerLabel` renders the
    /// suffix in `.font(.footnote)` — a Dynamic-Type *scaling* font — while a fixed `suffixReserve` does
    /// not. At large sizes the suffix would outgrow a fixed reserve and slide under the right-aligned
    /// number; scaling the reserve with the same setting keeps the two in step at every font size, so the
    /// number and the in-field unit never collide. Every short-suffix field shares the base `30`, so they
    /// stay in one column that grows together — no per-field scatter, and no classic-wheel blast radius
    /// (the shared `UITextPickerLabel` font is left untouched).
    @ScaledMetric private var reserveScale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .keyboardType(keyboardType)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            // Reserve the right for the in-field suffix, scaled with Large Text (see `reserveScale`);
            // nothing to reserve for a suffix-less field.
            .padding(.trailing, suffix.isEmpty ? 0 : suffixReserve * reserveScale)
            .frame(maxWidth: fullWidth ? .infinity : UIValueFieldStyle.fieldWidth)
            .overlay(alignment: .trailing) {
                if !suffix.isEmpty {
                    UITextPickerLabel(suffix).padding(.trailing, 8)
                }
            }
    }

    /// The canonical value-box width — wider than the old 96 so `kCals` and three-digit numbers have
    /// headroom. Every numeric entry shares it, so the boxes are equal regardless of input or UoM.
    static let fieldWidth: CGFloat = 110
}

#Preview {
    // The shared style across the three suffix regimes: a short unit, the wide `kCals`, and Age's `yrs`
    // unit. Each is right-aligned to a shared edge and shares the one Large-Text-scaled reserve.
    VStack(alignment: .trailing, spacing: 16) {
        TextField("kg", text: .constant("70"))
            .modifier(UIValueFieldStyle(suffix: "kg", fullWidth: false))
        TextField("kCals", text: .constant("250"))
            .modifier(UIValueFieldStyle(suffix: "kCals", suffixReserve: 44, fullWidth: false))
        TextField("yrs", text: .constant("32"))
            .modifier(UIValueFieldStyle(suffix: "yrs", fullWidth: false))
    }
    .padding()
}
