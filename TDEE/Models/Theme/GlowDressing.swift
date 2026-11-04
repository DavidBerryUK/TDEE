//
//  GlowDressing.swift
//  TDEE
//

import SwiftUI

/// One layer of a neon bloom.
///
/// A neon glow is a *tight bright core* compounded by a *wide soft halo* — two `.shadow` layers. `x`/`y`
/// default to 0 but are kept so a future offset or skew layer is a one-line addition. `Equatable` so it drops
/// into the `Equatable` dressings the way `SectionAccent` does.
struct GlowLayer: Equatable {
    /// The blur radius of the layer.
    let radius: CGFloat
    /// The layer's opacity.
    let opacity: Double
    var x: CGFloat = 0
    var y: CGFloat = 0
}

/// One bright inner line of a lit-tube card outline — the hot CORE that makes a border read as a lit neon tube
/// rather than a flat stroke. On a *light* field, where a coloured outer halo (a shadow on near-white) is
/// nearly invisible, this inner line is what actually registers as "lit". Kept a small struct of its own —
/// not a `GlowLayer` — so a future per-scheme core (colour / width / inset) is a one-field change, and so it
/// stays `Equatable` the way the dressings do.
struct TubeCore: Equatable {
    /// The bright core colour — near-white for a hot tube.
    let color: Color
    /// The core line width.
    let width: CGFloat
    /// Inset from the card edge, so the core sits *inside* the outer stroke as a concentric rounded rect.
    var inset: CGFloat = 0.6
}

/// How a theme dresses its cards with a neon bloom — a crisp rounded-rect OUTLINE plus a layered-shadow BLOOM
/// on every card, a lit-tube CORE (a bright inner line, optional), and (optionally) glowing section headings.
///
/// A `ColorPalette` carries one as `glow: GlowDressing?`. `nil` (the default) means *no glow at all*, so every
/// theme that doesn't opt in renders byte-for-byte unchanged and the frozen card/picker views are never edited —
/// the exact opt-in discipline `PickerDressing`/`SectionDressing` use, and the model-layer route the project's
/// picker-freeze rule prefers. When a dressing is present, the per-card glow COLOUR falls out of the existing
/// resolution (`resolved.sectionAccent ?? glow.stroke`), so the six-hue rainbow glow needs no per-card field.
struct GlowDressing: Equatable {
    /// The base outline / bloom / heading colour for any card that has no accent of its own (the calorie/result
    /// cards and the container cards). A dressed section card overrides it with its own `sectionAccent`.
    let stroke: Color
    /// The crisp neon outline width. 1.5 matches `UICardNumericResult`'s existing overlay, so the glow is the
    /// same card, not a thicker frame.
    var strokeWidth: CGFloat
    /// The tight bright core of the bloom (drawn first, so it sits inside the halo).
    let core: GlowLayer
    /// The wide soft halo of the bloom.
    let halo: GlowLayer
    /// Whether section headings carry a text bloom. A per-palette flag, so a heading that ever measures low can
    /// be flipped off here without a model change.
    let headingGlow: Bool
    /// A lit-tube core — a bright inner line inside the outline, so the border reads as a lit tube. This is the
    /// part that registers on a *light* field, where an outer halo alone is nearly invisible. `nil` (every
    /// dressing that doesn't opt in) draws just the one outline, exactly as before.
    let tubeCore: TubeCore?
    /// The heading text-bloom colour, overriding the per-section hue / house stroke that `neonHeading` would
    /// otherwise use. A *light* scheme sets this near-white so the titles read as clean lit text instead of a
    /// muddy saturated halo on a light field; `nil` (the default) keeps the hue, so dark Neon and every other
    /// scheme are unchanged.
    let headingColor: Color?

    init(
        stroke: Color,
        strokeWidth: CGFloat = 1.5,
        core: GlowLayer,
        halo: GlowLayer,
        headingGlow: Bool = true,
        tubeCore: TubeCore? = nil,
        headingColor: Color? = nil
    ) {
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.core = core
        self.halo = halo
        self.headingGlow = headingGlow
        self.tubeCore = tubeCore
        self.headingColor = headingColor
    }

    /// The full bloom on a near-black field: a tight, near-opaque core inside a wide, soft halo.
    static let full = GlowDressing(
        stroke: Color(hex: "#19E6FF"),
        core: GlowLayer(radius: 2.5, opacity: 0.95),
        halo: GlowLayer(radius: 16, opacity: 0.5)
    )

    /// A softened bloom for a light field, where a coloured halo barely reads — the crisp saturated outline
    /// carries the neon and the halo is gentle so it doesn't wash out on a near-white ground.
    static let fullLight = GlowDressing(
        stroke: Color(hex: "#005FBF"),
        core: GlowLayer(radius: 1.5, opacity: 0.6),
        halo: GlowLayer(radius: 9, opacity: 0.28)
    )

    /// `fullLight`, plus a bright inner core — a "lit tube" for a near-white field, where the halo alone
    /// doesn't register. The crisp saturated edge and the hot inner line are what read as neon; used by Neon's
    /// light scheme. The halo is widened (r15) so it reaches further, and the heading glow is a near-white
    /// (`headingColor`) so titles read as clean lit text rather than a muddy coloured halo on a light field.
    static let fullLightTube = GlowDressing(
        stroke: Color(hex: "#005FBF"),
        core: GlowLayer(radius: 1.5, opacity: 0.6),
        halo: GlowLayer(radius: 15, opacity: 0.3),
        tubeCore: TubeCore(color: .white, width: 0.75),
        headingColor: Color(hex: "#DDE8FF")
    )
}
