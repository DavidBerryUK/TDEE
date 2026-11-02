//
//  UIWheelBodyFatPlain.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: the .pickerStyle(.wheel) is intentional — a wheel is best for ordered numeric
// values, not a dropdown. DO NOT switch to `.pickerStyle(.menu)` and DO NOT remove the integer/decimal
// logic below; it is load-bearing.
//
// This is the PLAIN control: the original native SwiftUI `.pickerStyle(.wheel)` integer + decimal pair (its
// `develop` form), undressed. A parent (`SectionEditorBodyFatPercentage` / `BodyFatPercentageNewSectionView`)
// shows it for every theme that doesn't opt into picker colours, so it must stay visually identical to the
// pre-theming control — two native wheels, one number.
//
// The THEMED sibling (`UIWheelBodyFatThemed`) is the only place a theme dresses the wheel: it passes
// `forceAppearance: true` so each wheel renders as a `UIPickerView` (`UIThemedWheelPicker`) whose appearance
// is forced to light from the theme's `pickerColorScheme`, and it passes `pickerBackground` so EACH wheel is
// inset into its own rounded panel via `.pickerPanel(background:)` — the "." and "%" stay *outside* the
// panels (they are not wheels). A native `.pickerStyle(.wheel)`'s digits can't be coloured via
// `foregroundStyle` or a wrapper's `.preferredColorScheme` — so the appearance must be forced on the
// `UIPickerView` itself; only the themed path uses `UIThemedWheelPicker`.
//
// Renamed from `UIWheelPickerBodyFatView` as part of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelBodyFatPlain: View {
    @Environment(\.palette) private var palette

    @Binding var value: Double

    @State private var valueInteger: Int = 0
    @State private var valueDecimal: Int = 0

    var optionsInteger: [Int] = Array(0...99)
    var optionsDecimal: [Int] = Array(0...9)

    /// The panel colour each wheel is inset into, so the integer and decimal wheels each read as their
    /// own rounded-rect field. `nil` (the default — every non-opting theme) leaves each wheel bare,
    /// exactly as before; the themed sibling passes the active palette's `pickerBackground`. The "." and
    /// "%" stay *outside* the panels (they are not part of a wheel).
    var pickerBackground: Color? = nil

    /// Forces each wheel's digit colour dark via a forced light appearance. A native
    /// `.pickerStyle(.wheel)` ignores `foregroundStyle` and a wrapper's `.preferredColorScheme` does not
    /// reach its digit colour, so the themed sibling passes `true` to render each wheel as a `UIPickerView`
    /// (`UIThemedWheelPicker`) whose appearance is forced from the theme's `pickerColorScheme`. `false`
    /// (the default — every non-opting theme) keeps the original native wheel.
    var forceAppearance: Bool = false

    var body: some View {
        HStack(spacing: 4) {

            bodyFatWheel("Body fat percentage", selection: $valueInteger, rows: optionsInteger)
                .frame(width: 110)   // key change
                .accessibilityIdentifier("bodyFatPicker")
                .pickerPanel(background: pickerBackground) // per-wheel panel; bare when nil (plain)

            Text(".")
                .foregroundStyle(palette.textSecondary)
                .fontWeight(.black)

            bodyFatWheel("Body fat decimal", selection: $valueDecimal, rows: optionsDecimal)
                .frame(width: 110)   // key change
                .accessibilityIdentifier("bodyFatDecimalPicker")
                .pickerPanel(background: pickerBackground) // per-wheel panel; bare when nil (plain)

            Text("%")
                .foregroundStyle(palette.textSecondary)
                .padding(.leading, 2) // keeps it tight to it
        }
        .padding(.horizontal, 16) // page padding
        .onChange(of: valueInteger) {
            updateValue()
        }
        .onChange(of: valueDecimal) {
            updateValue()
        }
        .onAppear {
            // initialise from binding
            valueInteger = Int(value)
            valueDecimal = Int((value * 10).truncatingRemainder(dividingBy: 10))
        }
    }

    private func updateValue() {
        value = Double(valueInteger) + Double(valueDecimal) / 10.0
    }

    // The single wheel, shared by both: a `UIPickerView` with a forced appearance (themed, so the digits
    // read dark on the light panel) when `forceAppearance`, else the original native wheel. Keeping the
    // renderer choice in one place means the two wheels differ only in this renderer.
    @ViewBuilder
    private func bodyFatWheel(_ label: String, selection: Binding<Int>, rows: [Int]) -> some View {
        if forceAppearance {
            UIThemedWheelPicker(rows: rows, selection: selection)
        } else {
            Picker(label, selection: selection) {
                ForEach(rows, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

#Preview() {
    @Previewable @State var bodyFat: Double = 15.7
    UIWheelBodyFatPlain(value: $bodyFat)
}
