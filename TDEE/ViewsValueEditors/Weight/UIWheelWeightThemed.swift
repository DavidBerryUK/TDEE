//
//  UIWheelWeightThemed.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The THEMED weight wheel. It wraps the plain multi-unit wheel (`UIWheelWeightPlain`) and dresses it with
// the active theme: it forwards the palette's picker fields so EACH wheel insets into its own rounded-rect
// panel (so the highlighted row reads against a distinct field, and the stones & pounds wheels get
// separate panels rather than one shared), and passes `forceAppearance: true` so each wheel renders as a
// `UIPickerView` (`UIThemedWheelPicker`) whose appearance is forced to light from the theme's
// `pickerColorScheme`, making the digits read dark on the light panel. A native `.wheel`'s digits can't be
// coloured via `foregroundStyle` or a wrapper's `.preferredColorScheme` — the appearance must be forced on
// the `UIPickerView` itself (that's what `forceAppearance` does). A parent shows this instead of
// `UIWheelWeightPlain` when the active theme supplies picker colours. Part of the story-023 Themed/Plain
// split.

import SwiftUI

struct UIWheelWeightThemed: View {
    @Binding var value: Double
    @Binding var unitOfMeasure: OptionWeight

    @Environment(\.palette) private var palette

    var body: some View {
        UIWheelWeightPlain(
            value: $value,
            unitOfMeasure: $unitOfMeasure,
            pickerBackground: palette.pickerBackground,
            pickerPanelWidth: palette.pickerPanelWidth,
            pickerLabelOffsetX: palette.pickerLabelOffsetX,
            pickerFeetLabelOffsetX: palette.pickerFeetLabelOffsetX,
            pickerFeetInchesLabelOffsetX: palette.pickerFeetInchesLabelOffsetX,
            pickerWheelSpacing: palette.pickerWheelSpacing,
            forceAppearance: palette.pickerColorScheme != nil
        )
        .preferredColorScheme(palette.pickerColorScheme)
    }
}

#Preview("kilograms") {
    @Previewable @State var weight: Double = 21
    @Previewable @State var uom: OptionWeight = .kilograms
    UIWheelWeightThemed(value: $weight, unitOfMeasure: $uom)
}
