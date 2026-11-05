//
//  DefaultThemes.swift
//  TDEE
//
//  Hex values are from documentation/stories/story-018-themes/palettes.md.
//

import SwiftUI

enum ThemeID: String, CaseIterable, Identifiable {
    case standard
    case orange
    case clouds
    case turquoise
    case emerald
    case peterRiver
    case amethyst
    case sunflower
    case carrot
    case alizarin
    case highContrast
    case pride
    case neon
    case medical

    var id: String { rawValue }
}

enum DefaultThemes {

    static let all: [Theme] = [
        standard,
        orange,
        clouds,
        turquoise,
        emerald,
        peterRiver,
        amethyst,
        sunflower,
        carrot,
        alizarin,
        highContrast,
        pride,
        neon,
        medical,
    ]

    static func theme(for id: ThemeID) -> Theme {
        all.first { $0.id == id } ?? standard
    }

    /// The app's original look: iOS system dynamic colours, so one palette serves both schemes.
    static let standard: Theme = {
        let system = ColorPalette(
            primary: .blue,
            secondary: .red,
            background: Color(.systemGroupedBackground),
            surface: Color(.secondarySystemGroupedBackground),
            text: .primary,
            textSecondary: .secondary,
            border: Color(.separator),
            macroProtein: .red.opacity(0.85),
            macroCarbs: .blue,
            macroFat: .mint,
            editText: .red,
            highlight: Color(red: 0.25, green: 0.75, blue: 0.75),
            selection: .green
        )
        return Theme(id: .standard, name: "Default", description: "The app's original iOS system colours", light: system, dark: system)
    }()


    /// Bold coral on a black field (dark) / warm coral on white (light), after a Nike-run-club watch
    /// face. The two schemes are genuinely distinct palettes, so the theme follows the user's Appearance
    /// like every other theme — no `colorScheme` pin.
    ///
    /// **Dark:** `surface` is the coral; `primary` is *white* (not coral) because it colours CTA text
    /// that sits on the coral surface, so it must contrast it. `text` on coral is ~3.3:1 — fine for the
    /// large summary values, marginal for fine print; deepen `surface` toward `#C23B1E` for full AA.
    /// `editText`/`highlight`/`selection` are forced white (their default, `primary`, already is). The
    /// nav bar is themed to the black field and every section icon is the dark maroon accent, so both
    /// stay legible on the coral surface. Its wheel picker is dressed by adopting `PickerDressing.orange`
    /// — a light-coral panel, a forced light appearance, and the tuned caption offsets — so the picker's
    /// values live on that preset, not here.
    ///
    /// **Light:** the field inverts to a warm off-white with the coral kept as the accent, mirroring
    /// `carrot`'s light structure. `primary` is a *deep coral* (`#C24124`) so CTA/highlight text is
    /// legible on the white surface (5.1:1); `secondary` is the brand coral `#E8633F` (3.3:1, the vivid
    /// accent). Text is a deep maroon and `textSecondary` a warm brown-grey, both clear of AA on the warm
    /// ground. The macro colours match `carrot`'s light set — dark gold `#AE8E0A` fat (bright `#F1C40F`
    /// fails 3:1 on white). The light scheme swaps the maroon icons for a curated per-icon palette
    /// (coral/orange/teal/plum, each white-legible), so the sections read as distinct colours instead of
    /// one brown. The light picker stays **undressed** (a plain native wheel on white), so only the dark
    /// scheme adopts the orange dressing.
    static let orange: Theme = {
        // Dark scheme: one on-brand colour for every section icon — dark maroon reads crisply on the
        // coral surface (the built-in orange ruler was invisible on coral).
        let maroon = Color(hex: "#3A1512")
        let darkIcons: [Icon: Color] = Dictionary(
            Icon.allCases.map { ($0, maroon) },
            uniquingKeysWith: { first, _ in first }
        )

        // Light scheme: a curated per-icon palette — vibrant, warm-forward, each white-legible as a solid
        // chip (white glyph ≥3:1). A coral/orange family with a teal and a plum for variety, so the
        // sections read as distinct colours instead of one brown.
        let lightIcons: [Icon: Color] = [
            .gender:        Color(hex: "#EE6048"), // warm coral
            .age:           Color(hex: "#E8633F"), // brand orange
            .height:        Color(hex: "#D2691E"), // rich orange
            .weight:        Color(hex: "#2A9D8F"), // teal
            .activityLevel: Color(hex: "#D64545"), // energetic red
            .bodyFat:       Color(hex: "#B565A7"), // plum
            .calorie:       Color(hex: "#E8633F"), // flame = brand orange
            .protein:       Color(hex: "#D64545"),
            .carbs:         Color(hex: "#2A9D8F"),
            .fats:          Color(hex: "#C87F0A"), // dark gold: bright yellow fails 3:1 on white
            .macroSplit:    Color(hex: "#E8633F"),
        ]

        // The dark scheme: bright coral surface on a black field, white text.
        let coral = Color(hex: "#E8633F")      // the section / accent colour
        let deepCoral = Color(hex: "#D24E2C")  // a gentle deepening for the *expanded* content panel
        let darkPalette = ColorPalette(
            primary: .white,
            secondary: maroon,
            background: .black,
            surface: coral,
            text: .white,
            textSecondary: .white,
            border: .white.opacity(0.2),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F"),
            editText: .white,
            highlight: .white,
            selection: .white,
            // Opt into the theme overrides: a black nav bar matching the field, maroon icons, and a
            // gentle deep-coral content panel.
            toolbar: .init(background: .black, itemBackground: maroon),
            iconColors: darkIcons,
            expandedContentBackground: deepCoral,
            // The wheel picker is dressed by adopting `PickerDressing.orange` — a light-coral panel, a
            // forced light appearance, and the tuned caption offsets/spacing — instead of setting its
            // seven fields here. The values live on that preset (see PickerDressing.swift); a future
            // theme opts in the same way with `PickerDressing.panel(…)`.
            pickerDressing: .orange
        )

        // The light scheme: warm off-white field, deep-orange accent, warm-dark text, and a curated
        // per-icon palette (vibrant, not one brown). No pickerDressing, so the wheel stays a plain
        // native field on the white surface.
        let lightPalette = ColorPalette(
            primary: Color(hex: "#C24124"),      // deep coral: CTA/highlight text on white (5.1:1)
            secondary: Color(hex: "#E35A33"),    // deep brand orange (3.3:1 on white, margin on the warm ground)
            background: Color(hex: "#FDF1EA"),   // warm coral-tinted off-white field
            surface: .white,
            text: Color(hex: "#2A1712"),         // deep maroon body text
            textSecondary: Color(hex: "#6E5A50"),// warm brown-grey captions
            border: Color(hex: "#FBE4DA"),       // light coral-tinted dividers
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A"),     // dark gold: bright #F1C40F fails 3:1 on white
            // editText/highlight/selection default to primary (#C24124).
            toolbar: .init(background: Color(hex: "#FDF1EA"), itemBackground: Color(hex: "#F7C9B8")),
            iconColors: lightIcons,
            expandedContentBackground: Color(hex: "#FDF4EE")  // a barely-there warm panel, much lighter than the dark scheme's
        )

        return Theme(id: .orange, name: "Orange", description: "Bold coral on black", light: lightPalette, dark: darkPalette)
    }()


    static let clouds = Theme(
        id: .clouds,
        name: "Clouds",
        description: "Calm greys with a wet-asphalt accent",
        light: ColorPalette(
            primary: Color(hex: "#34495E"),
            secondary: Color(hex: "#7F8C8D"),
            background: Color(hex: "#F4F6F7"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#1E2A36"),
            textSecondary: Color(hex: "#536476"),
            border: Color(hex: "#D5DBDF"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#95A5A6"),
            secondary: Color(hex: "#7F8C8D"),
            background: Color(hex: "#121619"),
            surface: Color(hex: "#1C2226"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#92A1A6"),
            border: Color(hex: "#222C34"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F")
        )
    )


    static let turquoise = Theme(
        id: .turquoise,
        name: "Turquoise",
        description: "Fresh turquoise and green-sea",
        light: ColorPalette(
            primary: Color(hex: "#117D68"),
            secondary: Color(hex: "#34495E"),
            background: Color(hex: "#EFFAF8"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#1B383E"),
            textSecondary: Color(hex: "#46787C"),
            border: Color(hex: "#D1F2EB"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#1ABC9C"),
            secondary: Color(hex: "#587CA0"),
            background: Color(hex: "#0F1D1E"),
            surface: Color(hex: "#1A3232"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#8DB8B2"),
            border: Color(hex: "#1A554D"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F")
        )
    )


    static let emerald = Theme(
        id: .emerald,
        name: "Emerald",
        description: "Natural greens",
        light: ColorPalette(
            primary: Color(hex: "#1D8148"),
            secondary: Color(hex: "#16A085"),
            background: Color(hex: "#F0FBF5"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#1D3A39"),
            textSecondary: Color(hex: "#49786F"),
            border: Color(hex: "#D5F5E3"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#2ECC71"),
            secondary: Color(hex: "#16A085"),
            background: Color(hex: "#101E1B"),
            surface: Color(hex: "#1C342D"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#91BBAA"),
            border: Color(hex: "#205A3E"),
            macroProtein: Color(hex: "#E92366"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F"),
            // Full themed set for the dark scheme (mirrors Orange's dark treatment, in greens): a green
            // nav bar matching the field, a distinct per-icon palette — a natural greens-forward set
            // (forest / teal / goldenrod / slate / terracotta / plum, each white-legible as a solid
            // chip), a distinct green expanded panel, and a light-mint picker panel with forced-light
            // digits.
            toolbar: .init(background: Color(hex: "#101E1B"), itemBackground: Color(hex: "#1E7A4D")),
            iconColors: [
                .gender:        Color(hex: "#2E8B57"), // sea green
                .age:           Color(hex: "#157A5E"), // deep teal-green
                .height:        Color(hex: "#B8860B"), // goldenrod (sunlight)
                .weight:        Color(hex: "#3E7CB1"), // slate blue (water)
                .activityLevel: Color(hex: "#C25E3A"), // terracotta (energy)
                .bodyFat:       Color(hex: "#8E5BA6"), // plum (berry)
                .calorie:       Color(hex: "#D35400"), // pumpkin (flame)
                .protein:       Color(hex: "#E92366"), // pink-red
                .carbs:         Color(hex: "#3498DB"), // blue
                .fats:          Color(hex: "#B8860B"), // dark gold: bright #F1C40F fails 3:1 on white
                .macroSplit:    Color(hex: "#16A085"), // teal
            ],
            expandedContentBackground: Color(hex: "#24503F"),
            // Offsets left nil: a panel triggers the caption-beside layout, where they're inert
            // (UIWheelXxxPlain.wheelWithCaption), so the one-call `.panel(…)` opt-in is enough.
            pickerDressing: .panel(background: Color(hex: "#A8D5C4"), appearance: .light, width: 96)
        )
    )


    static let peterRiver = Theme(
        id: .peterRiver,
        name: "Peter River",
        description: "Clear sky blue",
        light: ColorPalette(
            primary: Color(hex: "#1F74AE"),
            secondary: Color(hex: "#17A388"),
            background: Color(hex: "#F1F8FC"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#1E3445"),
            textSecondary: Color(hex: "#507490"),
            border: Color(hex: "#D6EAF8"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#3D9CDD"),
            secondary: Color(hex: "#1ABC9C"),
            background: Color(hex: "#111A22"),
            surface: Color(hex: "#1D2E3A"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#92B1BF"),
            border: Color(hex: "#234862"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F")
        )
    )


    static let amethyst = Theme(
        id: .amethyst,
        name: "Amethyst",
        description: "Rich purple",
        light: ColorPalette(
            primary: Color(hex: "#9650B2"),
            secondary: Color(hex: "#E91E63"),
            background: Color(hex: "#F8F3FA"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#2A2C41"),
            textSecondary: Color(hex: "#6C688C"),
            border: Color(hex: "#EBDEF0"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#B17EC6"),
            secondary: Color(hex: "#E91E63"),
            background: Color(hex: "#18161F"),
            surface: Color(hex: "#292636"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#A7A4B8"),
            border: Color(hex: "#463356"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F")
        )
    )


    static let sunflower = Theme(
        id: .sunflower,
        name: "Sunflower",
        description: "Warm sunshine yellow",
        light: ColorPalette(
            primary: Color(hex: "#886E08"),
            secondary: Color(hex: "#DF7619"),
            background: Color(hex: "#FEFBEE"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#35392D"),
            textSecondary: Color(hex: "#747457"),
            border: Color(hex: "#FCF3CF"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#F1C40F"),
            secondary: Color(hex: "#E67E22"),
            background: Color(hex: "#1E1E14"),
            surface: Color(hex: "#343321"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#B8BA96"),
            border: Color(hex: "#63571D"),
            macroProtein: Color(hex: "#EB2E6E"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F")
        )
    )


    static let carrot = Theme(
        id: .carrot,
        name: "Carrot",
        description: "Energetic orange",
        light: ColorPalette(
            primary: Color(hex: "#AB5A13"),
            secondary: Color(hex: "#D35400"),
            background: Color(hex: "#FDF6F0"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#33312F"),
            textSecondary: Color(hex: "#7B6D64"),
            border: Color(hex: "#FAE5D3"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#E67E22"),
            secondary: Color(hex: "#D35400"),
            background: Color(hex: "#1D1915"),
            surface: Color(hex: "#322A24"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#B6AC9A"),
            border: Color(hex: "#5F3F24"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F")
        )
    )


    static let alizarin = Theme(
        id: .alizarin,
        name: "Alizarin",
        description: "Bold red",
        light: ColorPalette(
            primary: Color(hex: "#D32B1A"),
            secondary: Color(hex: "#C0392B"),
            background: Color(hex: "#FDF2F1"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#332B32"),
            textSecondary: Color(hex: "#80656E"),
            border: Color(hex: "#FADBD8"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#EB675A"),
            secondary: Color(hex: "#D03E2F"),
            background: Color(hex: "#1D1517"),
            surface: Color(hex: "#332427"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#B6A29F"),
            border: Color(hex: "#602E2C"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F")
        )
    )


    static let highContrast = Theme(
        id: .highContrast,
        name: "High Contrast",
        description: "Maximum legibility, single strong accent",
        light: ColorPalette(
            primary: Color(hex: "#0033CC"),
            secondary: Color(hex: "#000000"),
            background: Color(hex: "#EBEBEB"),
            surface: Color(hex: "#FFFFFF"),
            text: Color(hex: "#000000"),
            textSecondary: Color(hex: "#262626"),
            border: Color(hex: "#000000"),
            macroProtein: Color(hex: "#A3001B"),
            macroCarbs: Color(hex: "#0033CC"),
            macroFat: Color(hex: "#B36B00")
        ),
        dark: ColorPalette(
            primary: Color(hex: "#7FB2FF"),
            secondary: Color(hex: "#FFFFFF"),
            background: Color(hex: "#000000"),
            surface: Color(hex: "#1A1A1A"),
            text: Color(hex: "#FFFFFF"),
            textSecondary: Color(hex: "#E0E0E0"),
            border: Color(hex: "#FFFFFF"),
            macroProtein: Color(hex: "#FF8C9E"),
            macroCarbs: Color(hex: "#7FB2FF"),
            macroFat: Color(hex: "#FFC94D")
        )
    )


    /// **Pride** — the LGBTQ+ rainbow as one theme that follows the system Light/Dark setting: the subtle
    /// variant (each section a light tint of its swatch, wheels plain) in light mode, and the bold variant
    /// (each section filled with its swatch, wheels dressed to match) in dark mode. The two palettes below
    /// are the former `prideSoft` (light) and `pride` (dark) settings, **unchanged** — now sharing one
    /// theme with no pinned scheme, so the user's Appearance choice decides which shows. The section colours
    /// come from `SectionDressing.pride(...)`, expanded per section by `ColorPalette.resolved(for:)`; each
    /// base palette also serves the non-section result/macro cards on its own surface.
    static let pride: Theme = {
        // Dark mode: bold — each section filled with its swatch on a near-black field.
        let bold = ColorPalette(
            primary: .white,
            secondary: Color(hex: "#760089"),
            background: Color(hex: "#0B0B0F"),          // near-black field
            surface: Color(hex: "#1A1A22"),             // neutral card for the result/macro sections
            text: .white,
            textSecondary: Color(hex: "#C8C8D4"),
            border: Color(hex: "#2A2A36"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F"),
            editText: .white,
            highlight: .white,
            selection: .white,
            toolbar: .init(background: Color(hex: "#0B0B0F"), itemBackground: Color(hex: "#2A2A36")),
            expandedContentBackground: Color(hex: "#1F1F2A"),
            sectionDressing: SectionDressing.pride(.bold)
        )
        // Light mode: subtle — each section a light tint of its swatch on a warm off-white field, wheels plain.
        let subtle = ColorPalette(
            primary: Color(hex: "#5B0069"),   // deep magenta: reads on the light field for CTAs/selection
            secondary: Color(hex: "#E70000"),
            background: Color(hex: "#FBF7F5"), // warm off-white field
            surface: .white,                   // per-section tints override this for the input card
            text: Color(hex: "#1A1A22"),
            textSecondary: Color(hex: "#6A6A78"),
            border: Color(hex: "#ECE3E6"),
            macroProtein: Color(hex: "#E91E63"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A"),
            toolbar: .init(background: Color(hex: "#FBF7F5"), itemBackground: Color(hex: "#F0E6EA")),
            sectionDressing: SectionDressing.pride(.subtle)
        )
        return Theme(
            id: .pride, name: "Pride", description: "LGBTQ+ rainbow — subtle in light, bold in dark",
            light: subtle, dark: bold, colorScheme: nil
        )
    }()


    /// **Neon** — a per-section electric rainbow on a near-black field, with a crisp rounded-rect outline and a
    /// layered-shadow bloom on every card, plus glowing section headings. One net-new field, `glow: GlowDressing?`,
    /// switches the whole look on; every effect is gated on it, so the other themes render byte-for-byte unchanged
    /// and the frozen card/picker views are never edited.
    ///
    /// **Dark** is `SectionDressing.neon(.subtle, subtleIntensity: 0.1)`: each input card is a faint tint of its
    /// hue with a solid glowing border and a glow in that hue — the same restrained "neon card" as the
    /// result/macro boxes — on the near-black field; the result/macro cards glow the house cyan.
    ///
    /// **Light** is `SectionDressing.neon(.subtle, 0.12)` with a lit-tube glow (`.fullLightTube`): the same six
    /// hues as faint tints on a light cool-grey field (`#E7EAF4` page, `#F5F7FC` cards — light enough to stay
    /// clean, with just enough ground for a wide halo to register), a bright inner core on every card outline
    /// (the "lit tube"), a widened halo (r15), and a near-white heading glow so the titles read as clean lit
    /// text. The macros and the CTA/highlight are deepened (cyan `#19E6FF → #005FBF`) so text clears 4.5:1, and
    /// `editText` stays deep ink so an expanded value reads on the faint tint.
    ///
    /// No `colorScheme` pin, so the user's Appearance choice decides which shows. The per-section glow colour
    /// falls out of `resolved.sectionAccent`, so the rainbow needs no per-card field.
    static let neon: Theme = {
        let dark = ColorPalette(
            primary: Color(hex: "#19E6FF"),
            secondary: Color(hex: "#FF2E9A"),
            background: Color(hex: "#0A0A10"),
            surface: Color(hex: "#14141C"),
            text: Color(hex: "#F2F6FF"),
            textSecondary: Color(hex: "#9DA3C9"),
            border: Color(hex: "#2A2A40"),
            macroProtein: Color(hex: "#FF2E9A"),
            macroCarbs: Color(hex: "#19E6FF"),
            macroFat: Color(hex: "#FFD23F"),
            editText: .white,
            highlight: Color(hex: "#19E6FF"),
            selection: Color(hex: "#19E6FF"),
            toolbar: .init(background: Color(hex: "#0A0A10"), itemBackground: Color(hex: "#1E1E30")),
            iconColors: [
                .calorie:    Color(hex: "#FF7A1A"),
                .protein:    Color(hex: "#FF2E9A"),
                .carbs:      Color(hex: "#19E6FF"),
                .fats:       Color(hex: "#FFD23F"),
                .macroSplit: Color(hex: "#B14BFF"),
            ],
            expandedContentBackground: Color(hex: "#1A1A2C"),
            sectionDressing: SectionDressing.neon(.subtle, subtleIntensity: 0.1),
            glow: .full
        )

        let light = ColorPalette(
            primary: Color(hex: "#005FBF"),
            secondary: Color(hex: "#B0006A"),
            background: Color(hex: "#E7EAF4"),
            surface: Color(hex: "#F5F7FC"),
            text: Color(hex: "#141026"),
            textSecondary: Color(hex: "#5B5E7A"),
            border: Color(hex: "#C7D1E6"),
            macroProtein: Color(hex: "#C2185B"),
            macroCarbs: Color(hex: "#0072BC"),
            macroFat: Color(hex: "#AE8E0A"),
            editText: Color(hex: "#141026"),
            highlight: Color(hex: "#005FBF"),
            selection: Color(hex: "#005FBF"),
            toolbar: .init(background: Color(hex: "#E7EAF4"), itemBackground: Color(hex: "#DCE3F1")),
            iconColors: [
                .calorie:    Color(hex: "#E65100"),
                .protein:    Color(hex: "#C2185B"),
                .carbs:      Color(hex: "#0072BC"),
                .fats:       Color(hex: "#AE8E0A"),
                .macroSplit: Color(hex: "#7B2FE0"),
            ],
            expandedContentBackground: Color(hex: "#F4F6FC"),
            sectionDressing: SectionDressing.neon(.subtle, subtleIntensity: 0.12),
            glow: .fullLightTube
        )

        return Theme(id: .neon, name: "Neon", description: "Per-section electric rainbow with a glow — neon-on-dark, neon-on-light", light: light, dark: dark)
    }()


    /// **Medical** — a clean, clinical look: the design system's brand blue on a cool grey-5 page with
    /// white cards (light) and a deep navy field with a lightened-blue accent (dark). A single blue accent
    /// for links, CTAs, selection, highlight and every section icon — calm and legible, no glow or
    /// per-section dressing (a plain two-palette theme, like Clouds). It also sets the only `typeface`
    /// (`ThemeTypography.sourceSans3`, a bundled clinical sans); the system font is the default for every
    /// other theme. No `colorScheme` pin, so the user's Appearance choice decides which scheme shows.
    static let medical: Theme = {
        // One clinical-blue accent for every section icon, in each scheme (lightened for the dark field).
        func icons(_ hex: String) -> [Icon: Color] {
            let blue = Color(hex: hex)
            return Dictionary(Icon.allCases.map { ($0, blue) }, uniquingKeysWith: { first, _ in first })
        }

        // Light: brand blue on a cool grey-5 page, white cards. Clears the WCAG test — primary and
        // textSecondary ~6.4:1 on both page and surface, the three macros ≥ 3:1 on white.
        let light = ColorPalette(
            primary: Color(hex: "#005EB8"),        // clinical blue: links, CTAs, selection, highlight
            secondary: Color(hex: "#007F3B"),      // clinical green: success
            background: Color(hex: "#F0F4F5"),     // cool grey-5 page
            surface: .white,
            text: Color(hex: "#212B32"),           // near-black body text
            textSecondary: Color(hex: "#4C6272"),  // muted blue-grey captions
            border: Color(hex: "#D8DDE0"),         // light grey dividers
            macroProtein: Color(hex: "#E91E63"),   // shared CVD-safe macro trio
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#AE8E0A"),
            // editText / highlight / selection default to primary (clinical blue).
            toolbar: .init(background: Color(hex: "#F0F4F5"), itemBackground: Color(hex: "#DCE6EC")),
            iconColors: icons("#005EB8")
        )

        // Dark: a deep clinical navy field, a lightened-blue accent, white text.
        let dark = ColorPalette(
            primary: Color(hex: "#4C9BE8"),
            secondary: Color(hex: "#7DC35A"),
            background: Color(hex: "#0A1A24"),
            surface: Color(hex: "#12222E"),
            text: Color(hex: "#ECF0F1"),
            textSecondary: Color(hex: "#9DB8C9"),
            border: Color(hex: "#1E3A4A"),
            macroProtein: Color(hex: "#E92366"),
            macroCarbs: Color(hex: "#3498DB"),
            macroFat: Color(hex: "#F1C40F"),
            toolbar: .init(background: Color(hex: "#0A1A24"), itemBackground: Color(hex: "#16303F")),
            iconColors: icons("#4C9BE8")
        )

        return Theme(
            id: .medical,
            name: "Medical",
            description: "Clean clinical blue on a calm field — a bundled sans typeface",
            light: light,
            dark: dark,
            typeface: .sourceSans3
        )
    }()

}
