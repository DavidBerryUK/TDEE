import Testing
@testable import TDEE
import SwiftUI
import UIKit

// MARK: - PickerDressing Tests
//
// Regression guard for the model-layer picker generalisation (story-024): a `PickerDressing` bundles the
// picker's seven fields, and `DefaultThemes.orange` adopts `.orange`. These assert the dressing
// reproduces exactly the values the theme passed before the generalisation, so the frozen picker views
// render identically. The four caption/spacing fields are inert in Orange's caption-beside layout but
// are preserved — see `PickerDressing.orange`.

@Suite("PickerDressing Tests")
struct PickerDressingTests {

    @Test("plain is undressed: all seven fields nil, not themed")
    func testPlain() {
        let d = PickerDressing.plain
        #expect(d.background == nil)
        #expect(d.colorScheme == nil)
        #expect(d.panelWidth == nil)
        #expect(d.labelOffsetX == nil)
        #expect(d.feetLabelOffsetX == nil)
        #expect(d.feetInchesLabelOffsetX == nil)
        #expect(d.wheelSpacing == nil)
        #expect(d.isThemed == false)
    }

    @Test("orange reproduces the theme's former picker fields exactly")
    func testOrangeReproduces() {
        let d = PickerDressing.orange
        #expect(hex(d.background) == "#F8D0C5", "panel background")
        #expect(d.colorScheme == .light)
        #expect(d.panelWidth == 96)
        #expect(d.labelOffsetX == 78)
        #expect(d.feetLabelOffsetX == 74)
        #expect(d.feetInchesLabelOffsetX == 82)
        #expect(d.wheelSpacing == 60)
        #expect(d.isThemed == true)
    }

    @Test("the panel factory sets only the panel fields and leaves the offsets nil")
    func testPanelFactory() {
        let d = PickerDressing.panel(background: Color(hex: "#123456"), appearance: .dark, width: 80)
        #expect(hex(d.background) == "#123456")
        #expect(d.colorScheme == .dark)
        #expect(d.panelWidth == 80)
        #expect(d.labelOffsetX == nil)
        #expect(d.feetLabelOffsetX == nil)
        #expect(d.feetInchesLabelOffsetX == nil)
        #expect(d.wheelSpacing == nil)
        #expect(d.isThemed == true)
    }

    @Test("ColorPalette expands a dressing into its seven stored fields")
    func testExpansion() {
        let palette = ColorPalette(
            primary: .blue, secondary: .red, background: .white, surface: .white,
            text: .black, textSecondary: .gray, border: .gray,
            macroProtein: .red, macroCarbs: .blue, macroFat: .green,
            pickerDressing: .orange
        )
        #expect(hex(palette.pickerBackground) == "#F8D0C5")
        #expect(palette.pickerColorScheme == .light)
        #expect(palette.pickerPanelWidth == 96)
        #expect(palette.pickerLabelOffsetX == 78)
        #expect(palette.pickerFeetLabelOffsetX == 74)
        #expect(palette.pickerFeetInchesLabelOffsetX == 82)
        #expect(palette.pickerWheelSpacing == 60)
        #expect(palette.isPickerThemed == true)
    }

    @Test("no dressing leaves the picker fields nil (plain)")
    func testNoDressingIsPlain() {
        let palette = ColorPalette(
            primary: .blue, secondary: .red, background: .white, surface: .white,
            text: .black, textSecondary: .gray, border: .gray,
            macroProtein: .red, macroCarbs: .blue, macroFat: .green
        )
        #expect(palette.pickerBackground == nil)
        #expect(palette.pickerColorScheme == nil)
        #expect(palette.pickerPanelWidth == nil)
        #expect(palette.pickerLabelOffsetX == nil)
        #expect(palette.isPickerThemed == false)
    }

    @Test("DefaultThemes.Orange dark adopts the orange dressing")
    func testOrangeThemeAdoptsDressing() {
        let palette = DefaultThemes.orange.dark
        #expect(hex(palette.pickerBackground) == "#F8D0C5")
        #expect(palette.pickerColorScheme == .light)
        #expect(palette.pickerPanelWidth == 96)
        #expect(palette.pickerLabelOffsetX == 78)
        #expect(palette.isPickerThemed == true)
    }

    @Test("DefaultThemes.Orange light stays undressed (plain native wheel)")
    func testOrangeLightIsPlain() {
        let palette = DefaultThemes.orange.light
        #expect(palette.pickerBackground == nil)
        #expect(palette.pickerColorScheme == nil)
        #expect(palette.pickerPanelWidth == nil)
        #expect(palette.pickerLabelOffsetX == nil)
        #expect(palette.isPickerThemed == false)
    }

    @Test("themes that don't opt in stay undressed (plain)")
    func testPlainThemesStayUndressed() {
        // Orange and Emerald dress their DARK pickers; every other theme — and their own light palettes
        // — stay undressed (the native wheel).
        for theme in DefaultThemes.all {
            #expect(theme.light.isPickerThemed == false, "\(theme.name) light should be undressed")
            if theme.id != .orange && theme.id != .emerald {
                #expect(theme.dark.isPickerThemed == false, "\(theme.name) dark should be undressed")
            }
        }
        #expect(DefaultThemes.orange.dark.isPickerThemed == true, "Orange dark should be themed")
        #expect(DefaultThemes.emerald.dark.isPickerThemed == true, "Emerald dark should be themed")
    }

    // MARK: - Helpers (mirrors ThemeTests: Color is not Equatable, so compare via hex)

    private func components(_ color: Color) -> (Double, Double, Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    private func hex(_ color: Color?) -> String {
        guard let color else { return "nil" }
        let (r, g, b) = components(color)
        return String(format: "#%02X%02X%02X", Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded()))
    }
}
