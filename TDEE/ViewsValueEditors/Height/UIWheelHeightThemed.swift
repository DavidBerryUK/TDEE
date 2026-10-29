//
//  UIWheelHeightThemed.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The THEMED height wheel. It reuses the plain multi-unit wheel (UIWheelHeightPlain) unchanged and
// dresses it with the active theme: a rounded-rect panel behind the picker (so the highlighted row
// reads against a distinct field) and a forced light appearance (so the digits read on a light
// panel). A multi-unit layout can't take a themed selection band — that's a single-wheel
// ThemedWheelPicker concern — so the band stays the system's: the "wrap the whole group" choice. A
// parent shows this instead of UIWheelHeightPlain when the active theme supplies picker colours. Part
// of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelHeightThemed: View {
    @Binding var value: Double
    @Binding var unitOfMeasure: OptionLength

    @Environment(\.palette) private var palette

    var body: some View {
        UIWheelHeightPlain(value: $value, unitOfMeasure: $unitOfMeasure)
            .pickerPanel(background: palette.pickerBackground)
            .preferredColorScheme(palette.pickerColorScheme)
    }
}

#Preview("centimeters") {
    @Previewable @State var height: Double = 200
    @Previewable @State var uom: OptionLength = .centimeters
    UIWheelHeightThemed(value: $height, unitOfMeasure: $uom)
}
