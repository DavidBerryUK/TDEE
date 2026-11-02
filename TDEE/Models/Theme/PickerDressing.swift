//
//  PickerDressing.swift
//  TDEE
//

import SwiftUI

/// How a theme dresses its wheel pickers — the picker's optional fields bundled as one coherent unit, so
/// a theme ADOPTS a dressing instead of hand-tuning several magic numbers that only cohere for one theme.
///
/// The seven fields stay *stored* on `ColorPalette` — the frozen `UIWheel*Themed` / `UIWheel*Plain` views
/// read `palette.pickerBackground` … `palette.pickerWheelSpacing` directly — so a `PickerDressing` is
/// expanded INTO those fields when a `ColorPalette` is built (`ColorPalette(pickerDressing:)`). The views
/// never learn about this type; only the theme model does. That is the whole point of the generalisation:
/// the dressing lives in the model layer, and the picker views stay untouched.
///
/// `nil` / `.plain` is the undressed native wheel (every theme that doesn't opt in — the `ColorPalette`
/// default). `.orange` reproduces the one theme that currently dresses its picker; `.panel(…)` is the
/// one-call opt-in a future theme uses.
struct PickerDressing {

    // MARK: The seven picker fields, mirroring what `ColorPalette` stores and the frozen views read.

    /// The wheel's own panel background (a rounded rect around each wheel); `nil` = no panel.
    let background: Color?
    /// The wheel's forced appearance so its digits read on a panel; `nil` = the app's scheme.
    let colorScheme: ColorScheme?
    /// The panel's fixed width, insetting each wheel into a narrower field; `nil` = natural width.
    let panelWidth: CGFloat?
    /// The unit caption's x-offset; `nil` = the wheel's own caption position.
    let labelOffsetX: CGFloat?
    /// The feet caption's x-offset within a compound unit; `nil` falls back to `labelOffsetX`.
    let feetLabelOffsetX: CGFloat?
    /// The feet-&-inches ("inches") caption's x-offset; `nil` falls back to `labelOffsetX`.
    let feetInchesLabelOffsetX: CGFloat?
    /// The gap between the two wheels of a compound unit; `nil` = the group's natural spacing.
    let wheelSpacing: CGFloat?

    /// The undressed native wheel: no panel, no forced appearance, natural width, the wheel's own caption
    /// position. Every theme that doesn't opt in. This is `ColorPalette`'s all-nil picker default, so a
    /// theme that passes no dressing is identical to today.
    static var plain: PickerDressing { PickerDressing() }

    init(
        background: Color? = nil,
        colorScheme: ColorScheme? = nil,
        panelWidth: CGFloat? = nil,
        labelOffsetX: CGFloat? = nil,
        feetLabelOffsetX: CGFloat? = nil,
        feetInchesLabelOffsetX: CGFloat? = nil,
        wheelSpacing: CGFloat? = nil
    ) {
        self.background = background
        self.colorScheme = colorScheme
        self.panelWidth = panelWidth
        self.labelOffsetX = labelOffsetX
        self.feetLabelOffsetX = feetLabelOffsetX
        self.feetInchesLabelOffsetX = feetInchesLabelOffsetX
        self.wheelSpacing = wheelSpacing
    }

    /// Whether this dressing actually dresses the picker — the same predicate
    /// `ColorPalette.isPickerThemed` uses (`background != nil || colorScheme != nil`). `.plain` is never
    /// themed, so a plain-dressed theme stays on the undressed native wheel.
    var isThemed: Bool { background != nil || colorScheme != nil }

    // MARK: Named dressings

    /// The Orange theme's dressing: a light-coral panel around each wheel, forced light appearance so the
    /// digits read on it, a 96-pt panel width, and Orange's tuned compound-unit caption offsets and
    /// inter-wheel gap.
    ///
    /// The last four values (`labelOffsetX` / `feetLabelOffsetX` / `feetInchesLabelOffsetX` /
    /// `wheelSpacing`) apply only to the *plain* caption-over layout; in Orange's caption-beside layout
    /// they are inert. They are preserved here so `.orange` reproduces exactly what the theme passed before
    /// the generalisation — and a future layout change would pick them up without a theme edit.
    static let orange: PickerDressing = {
        // A light tint of the section coral for the wheel picker's own panel: the highlighted row was
        // barely visible on the coral, so the picker is inset into this light field (a tint of the coral
        // itself, so the panel reads as part of the orange family).
        let lightCoral = Color(hex: "#F8D0C5")
        return PickerDressing(
            background: lightCoral,
            colorScheme: .light,
            panelWidth: 96,
            labelOffsetX: 78,
            feetLabelOffsetX: 74,
            feetInchesLabelOffsetX: 82,
            wheelSpacing: 60
        )
    }()

    // MARK: Factories

    /// A themed picker a future theme can adopt with one call: a panel of `background`, an optional forced
    /// `appearance` (so its digits read on the panel), and an optional panel `width`.
    ///
    /// The compound-unit caption offsets and inter-wheel gap are left `nil` — inert in the caption-beside
    /// layout a panel triggers — so the factory stays a single-line opt-in. A theme that later needs the
    /// plain (caption-over) layout can pass them explicitly via the memberwise `init`.
    static func panel(
        background: Color,
        appearance: ColorScheme? = nil,
        width: CGFloat? = nil
    ) -> PickerDressing {
        PickerDressing(background: background, colorScheme: appearance, panelWidth: width)
    }
}
