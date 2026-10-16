//
//  DefaultThemes.swift
//  TDEE
//
//  Hex values are from documentation/stories/story-018-themes/palettes.md.
//

import SwiftUI

enum ThemeID: String, CaseIterable, Identifiable {
    case standard
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
            macroFat: .mint
        )
        return Theme(id: .standard, name: "Default", description: "The app's original iOS system colours", light: system, dark: system)
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
            macroFat: Color(hex: "#F1C40F")
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
            background: Color(hex: "#FFFFFF"),
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
            surface: Color(hex: "#000000"),
            text: Color(hex: "#FFFFFF"),
            textSecondary: Color(hex: "#E0E0E0"),
            border: Color(hex: "#FFFFFF"),
            macroProtein: Color(hex: "#FF8C9E"),
            macroCarbs: Color(hex: "#7FB2FF"),
            macroFat: Color(hex: "#FFC94D")
        )
    )

}
