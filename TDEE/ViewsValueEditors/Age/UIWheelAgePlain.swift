//
//  UIWheelAgePlain.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The PLAIN (standard-theme) age wheel: a raw native SwiftUI `.pickerStyle(.wheel)` with no theme
// dressing — and, unlike its orange sibling `UIWheelAgeThemed`, its "age in years" caption sits *over*
// the wheel. The caption is a `UITextPickerLabel` overlaid in a ZStack and nudged right, the same way
// the height section's "centimeters" caption sits over its wheel in a standard theme (see
// UIWheelHeightPlain.UIPickerViewCentimeters). A parent (`SectionEditorAge`) shows this one for every
// theme that doesn't opt into picker colours; the orange theme shows `UIWheelAgeThemed`, which instead
// pushes "age in years" *outside* the picker, to the section's right edge. Part of the story-023
// Themed/Plain split.

import SwiftUI

struct UIWheelAgePlain: View {
    @Binding var value: Int
    // Story 023, input #2: the accepted range lives in MetricRanges.age so the New text input and
    // this wheel agree on it.
    var optionsAge: [Int] = Array(MetricRanges.age)

    var body: some View {
        // The wheel is full-width, like the height section's "centimeters" wheel: a height only, no
        // fixed width, so it fills the section's content width (the section's own edge inset is the
        // "some padding"). This mirrors UIWheelHeightPlain.UIPickerViewCentimeters exactly.
        //
        // The caption "age in years" sits *over* the wheel — the standard-theme layout, unlike the
        // orange UIWheelAgeThemed which pushes it outside to the section's edge. It mirrors the height
        // section's "centimeters" caption: a UITextPickerLabel centred on the wheel and nudged right,
        // so it reads as the wheel's own caption rather than a label at the section's edge.
        ZStack {
            // The raw native wheel — no theme dressing, the plain sibling of UIWheelAgeThemed.
            Picker("Age", selection: $value) {
                ForEach(optionsAge, id: \.self) { option in
                    Text("\(option)").tag(option)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .accessibilityIdentifier("agePicker")

            // 60 mirrors the height section's "centimeters" caption offset (UIWheelHeightPlain's
            // `pickerLabelOffsetX ?? 60`).
            UITextPickerLabel("age in years")
                .offset(x: 60)
        }
        .padding(.horizontal, Spacing.large)
    }
}

#Preview("age") {
    @Previewable @State var selectedAge: Int = 21
    UIWheelAgePlain(value: $selectedAge)
}
