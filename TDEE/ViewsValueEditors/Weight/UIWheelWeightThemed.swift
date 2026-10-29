//
//  UIWheelWeightThemed.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The THEMED weight wheel. It reuses the plain multi-unit wheel (UIWheelWeightPlain) unchanged and
// dresses it with the active theme: a rounded-rect panel behind the picker (so the highlighted row
// reads against a distinct field) and a forced light appearance (so the digits read on a light
// panel). A multi-unit layout can't take a themed selection band — that's a single-wheel
// ThemedWheelPicker concern — so the band stays the system's: the "wrap the whole group" choice. A
// parent shows this instead of UIWheelWeightPlain when the active theme supplies picker colours. Part
// of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelWeightThemed: View {
    @Binding var value: Double
    @Binding var unitOfMeasure: OptionWeight

    @Environment(\.palette) private var palette

    var body: some View {
        UIWheelWeightPlain(value: $value, unitOfMeasure: $unitOfMeasure)
            .pickerPanel(background: palette.pickerBackground)
            .preferredColorScheme(palette.pickerColorScheme)
    }
}

#Preview("kilograms") {
    @Previewable @State var weight: Double = 21
    @Previewable @State var uom: OptionWeight = .kilograms
    UIWheelWeightThemed(value: $weight, unitOfMeasure: $uom)
}
