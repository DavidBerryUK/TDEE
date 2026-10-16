import Testing
@testable import TDEE
import SwiftUI
import UIKit

// MARK: - ThemeManager Tests

@Suite("ThemeManager Tests")
@MainActor
struct ThemeManagerTests {

    /// A fresh, isolated defaults store per test.
    private func makeDefaults() -> UserDefaults {
        let name = "ThemeTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test("Defaults to Default theme and Auto when nothing is stored")
    func testDefaults() {
        let manager = ThemeManager(defaults: makeDefaults())

        #expect(manager.themeID == .standard)
        #expect(manager.appearance == .auto)
        #expect(manager.theme.name == "Default")
    }

    @Test("Theme and appearance persist across instances")
    func testPersistenceRoundTrip() {
        let defaults = makeDefaults()
        let manager = ThemeManager(defaults: defaults)

        manager.themeID = .amethyst
        manager.appearance = .dark

        let reloaded = ThemeManager(defaults: defaults)
        #expect(reloaded.themeID == .amethyst)
        #expect(reloaded.appearance == .dark)
        #expect(reloaded.theme.name == "Amethyst")
    }

    @Test("Invalid stored values fall back to defaults")
    func testInvalidStoredValues() {
        let defaults = makeDefaults()
        defaults.set("holiday", forKey: ThemeManager.Keys.themeID)
        defaults.set("sepia", forKey: ThemeManager.Keys.appearance)

        let manager = ThemeManager(defaults: defaults)

        #expect(manager.themeID == .standard)
        #expect(manager.appearance == .auto)
    }

    @Test("Appearance modes map to colour schemes")
    func testAppearanceColorScheme() {
        #expect(AppearanceMode.auto.colorScheme == nil)
        #expect(AppearanceMode.light.colorScheme == .light)
        #expect(AppearanceMode.dark.colorScheme == .dark)
    }
}

// MARK: - DefaultThemes Tests

@Suite("DefaultThemes Tests")
struct DefaultThemesTests {

    @Test("All 10 themes exist, one per ID, Default first")
    func testAllThemes() {
        let ids = DefaultThemes.all.map(\.id)

        #expect(ids.count == 10)
        #expect(Set(ids) == Set(ThemeID.allCases))
        #expect(ids.first == .standard)
        for id in ThemeID.allCases {
            #expect(DefaultThemes.theme(for: id).id == id)
        }
    }

    @Test("Palette resolves by colour scheme")
    func testPaletteForScheme() {
        let theme = DefaultThemes.turquoise

        #expect(hex(theme.palette(for: .light).background) == hex(theme.light.background))
        #expect(hex(theme.palette(for: .dark).background) == hex(theme.dark.background))
        #expect(hex(theme.light.background) != hex(theme.dark.background))
    }

    @Test("Hex initialiser parses #RRGGBB")
    func testHexInit() {
        #expect(hex(Color(hex: "#1ABC9C")) == "#1ABC9C")
        #expect(hex(Color(hex: "E74C3C")) == "#E74C3C")
    }

    /// Default is skipped: it deliberately keeps the app's original system colours.
    @Test("Every themed palette meets WCAG contrast", arguments: DefaultThemes.all.filter { $0.id != .standard })
    func testContrast(theme: Theme) {
        let textMinimum = theme.id == .highContrast ? 7.0 : 4.5

        for (scheme, palette) in [("light", theme.light), ("dark", theme.dark)] {
            let label = "\(theme.name) \(scheme)"
            let pairs: [(String, Color, Color, Double)] = [
                ("text on background", palette.text, palette.background, textMinimum),
                ("text on surface", palette.text, palette.surface, textMinimum),
                ("textSecondary on surface", palette.textSecondary, palette.surface, textMinimum),
                ("textSecondary on background", palette.textSecondary, palette.background, textMinimum),
                ("primary on surface", palette.primary, palette.surface, textMinimum),
                ("primary on background", palette.primary, palette.background, textMinimum),
                ("secondary on surface", palette.secondary, palette.surface, 3.0),
                ("macroProtein on surface", palette.macroProtein, palette.surface, 3.0),
                ("macroCarbs on surface", palette.macroCarbs, palette.surface, 3.0),
                ("macroFat on surface", palette.macroFat, palette.surface, 3.0),
            ]
            for (name, foreground, background, minimum) in pairs {
                let ratio = contrast(foreground, background)
                #expect(ratio >= minimum, "\(label): \(name) is \(ratio), needs \(minimum)")
            }
        }
    }

    // MARK: - Helpers

    private func components(_ color: Color) -> (Double, Double, Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    private func hex(_ color: Color) -> String {
        let (r, g, b) = components(color)
        return String(format: "#%02X%02X%02X", Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded()))
    }

    private func luminance(_ color: Color) -> Double {
        let (r, g, b) = components(color)
        func linear(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
    }

    private func contrast(_ a: Color, _ b: Color) -> Double {
        let (la, lb) = (luminance(a), luminance(b))
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }
}
