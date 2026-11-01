//
//  UIWheelBodyFatThemed.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The THEMED body-fat-percentage wheel. It wraps the plain integer + decimal pair (`UIWheelBodyFatPlain`)
// and dresses it with the active theme: it passes `forceAppearance: true` so each wheel renders as a
// `UIPickerView` (`UIThemedWheelPicker`) whose appearance is forced to light from the theme's
// `pickerColorScheme`, and insets the whole integer.decimal group into ONE rounded-rect panel via
// `.pickerPanel(background:)` — a single number reads as one field, unlike the feet-&-inches / stones-&
// pounds split. A native `.wheel`'s digits can't be coloured via `foregroundStyle` or a wrapper's
// `.preferredColorScheme` — the appearance must be forced on the `UIPickerView` itself (that's what
// `forceAppearance` does). A parent shows this instead of `UIWheelBodyFatPlain` when the active theme
// supplies picker colours. Part of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelBodyFatThemed: View {
    @Binding var value: Double

    @Environment(\.palette) private var palette

    var body: some View {
        UIWheelBodyFatPlain(
            value: $value,
            forceAppearance: palette.pickerColorScheme != nil
        )
        .pickerPanel(background: palette.pickerBackground)
        .preferredColorScheme(palette.pickerColorScheme)
    }
}

#Preview() {
    @Previewable @State var bodyFat: Double = 15.7
    UIWheelBodyFatThemed(value: $bodyFat)
}
