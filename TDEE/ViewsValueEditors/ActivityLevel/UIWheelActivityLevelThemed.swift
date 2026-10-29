//
//  UIWheelActivityLevelThemed.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The THEMED activity-level wheel. Activity level is a single categorical wheel, so it's a
// ThemedWheelPicker — a `UIPickerView` a theme fully dresses (forced light appearance, themed
// selection band, transparent field) — inset into the theme's panel. The plain sibling
// (UIWheelActivityLevelPlain) is a raw SwiftUI .pickerStyle(.wheel). A parent shows this instead of
// the plain wheel when the active theme supplies picker colours. Part of the story-023 Themed/Plain
// split.

import SwiftUI

struct UIWheelActivityLevelThemed: View {
    @Binding var value: ActivityLevel

    @Environment(\.palette) private var palette

    var body: some View {
        VStack {
            Text("Activity Level")
                .accessibilityLabel("Activity level selector")

            // A themed categorical wheel; its display string is ActivityLevel.displayName.
            UIThemedWheelPicker(
                rows: ActivityLevel.allCases,
                selection: $value,
                rowText: { $0.displayName }
            )
            .frame(width: 220, height: 150)
            .accessibilityIdentifier("activityLevelPicker")
            .pickerPanel(background: palette.pickerBackground)
        }
    }
}

#Preview("activity level") {
    @Previewable @State var option: ActivityLevel = .sedentary
    UIWheelActivityLevelThemed(value: $option)
}
