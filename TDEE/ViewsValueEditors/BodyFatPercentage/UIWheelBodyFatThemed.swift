//
//  UIWheelBodyFatThemed.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The THEMED body-fat-percentage wheel. It reuses the plain integer + decimal wheel pair
// (UIWheelBodyFatPlain) unchanged and dresses it with the active theme: a rounded-rect panel behind
// the wheels (so the highlighted rows read against a distinct field) and a forced light appearance
// (so the digits read on a light panel). Two fixed wheels can't take a themed selection band — that's
// a single-wheel ThemedWheelPicker concern — so the bands stay the system's: the "wrap the whole
// group" choice. A parent shows this instead of UIWheelBodyFatPlain when the active theme supplies
// picker colours. Part of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelBodyFatThemed: View {
    @Binding var value: Double

    @Environment(\.palette) private var palette

    var body: some View {
        UIWheelBodyFatPlain(value: $value)
            .pickerPanel(background: palette.pickerBackground)
            .preferredColorScheme(palette.pickerColorScheme)
    }
}

#Preview() {
    @Previewable @State var bodyFat: Double = 15.7
    UIWheelBodyFatThemed(value: $bodyFat)
}
