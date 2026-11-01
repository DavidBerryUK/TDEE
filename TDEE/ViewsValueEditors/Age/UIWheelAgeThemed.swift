//
//  UIWheelAgeThemed.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: the .pickerStyle(.wheel) is intentional — a wheel is best for ordered numeric
// values, not a dropdown. This is the THEMED (orange) age wheel: a ThemedWheelPicker (a `UIPickerView`
// a theme can fully dress — a forced light appearance and a transparent field) inset into the theme's
// panel. Unlike its plain sibling (`UIWheelAgePlain`), its "age in years" caption sits *outside* the
// picker — a `Spacer` pushes it to the section's right edge, over the section content rather than the
// wheel; this is the orange-theme layout the standard themes don't get. A parent (`SectionEditorAge`)
// shows this instead of `UIWheelAgePlain` when the active theme supplies picker colours. Renamed from
// `UIWheelPickerAgeView` as part of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelAgeThemed: View {
    @Environment(\.palette) private var palette

    @Binding var value: Int
    // Story 023, input #2: the accepted range now lives in one place (MetricRanges.age) so the New
    // text input and this wheel agree on it. This is the only change to the array's data source.
    var optionsAge: [Int] = Array(MetricRanges.age)

    var body: some View {
        HStack {
            // A `UIPickerView`-backed wheel that a theme dresses itself: forced light appearance so the
            // digits read on a light panel, and a transparent field for the
            // panel — all read from the active theme, so it stays a one-line call site. Still a wheel,
            // not a menu.
            UIThemedWheelPicker(rows: optionsAge, selection: $value)
                .frame(width: 160, height: 150)
                .accessibilityIdentifier("agePicker")
            // When the theme opts in, just the picker sits in a rounded-rect panel; the "age in years"
            // label stays outside, on the section content.
            .pickerPanel(background: palette.pickerBackground)

            Spacer()

            Text("age in years")
                .foregroundStyle(palette.textSecondary)
        }
        .padding(.horizontal, Spacing.large)
    }
}

#Preview("age") {
    @Previewable @State var selectedAge: Int = 21
    UIWheelAgeThemed(value: $selectedAge)
}
