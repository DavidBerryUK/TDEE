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

}
