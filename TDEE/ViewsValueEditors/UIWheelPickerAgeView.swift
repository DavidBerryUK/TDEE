//
//  UIWheelPickerAgeView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a wheel picker for age selection.
// The .pickerStyle(.wheel) is intentional - wheel pickers are best for ordered numeric values.
// Changing to .pickerStyle(.menu) would create a dropdown which is less user-friendly for age.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UIWheelPickerAgeView: View {
    @Environment(\.palette) private var palette

    @Binding var value: Int
    // Story 023, input #2: the accepted range now lives in one place (MetricRanges.age) so the New
    // text input and this wheel agree on it. This is the only change to the array's data source.
    var optionsAge: [Int] = Array(MetricRanges.age)

    var body: some View {
        HStack {
            // A `UIPickerView`-backed wheel that a theme dresses itself: forced light appearance so the
            // digits read on a light panel, a themed selection band, and a transparent field for the
            // panel — all read from the active theme, so it stays a one-line call site. Still a wheel,
            // not a menu.
            ThemedWheelPicker(rows: optionsAge, selection: $value)
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
    UIWheelPickerAgeView(value: $selectedAge)
}
