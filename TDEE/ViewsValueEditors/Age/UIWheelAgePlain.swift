//
//  UIWheelAgePlain.swift
//  TDEE
//
//  Created by David Berry on 29/10/2026.
//

// The PLAIN age wheel: a raw SwiftUI .pickerStyle(.wheel) with no theme dressing. Its themed sibling
// (UIWheelAgeThemed) dresses the picker with the active theme. A parent shows this one unless the
// active theme supplies picker colours, in which case it shows UIWheelAgeThemed instead. Part of the
// story-023 Themed/Plain split.

import SwiftUI

struct UIWheelAgePlain: View {
    @Binding var value: Int
    // Story 023, input #2: the accepted range lives in MetricRanges.age so the New text input and
    // this wheel agree on it.
    var optionsAge: [Int] = Array(MetricRanges.age)

    var body: some View {
        HStack {
            // The raw SwiftUI wheel — no theme dressing, the plain sibling of UIWheelAgeThemed.
            Picker("Age", selection: $value) {
                ForEach(optionsAge, id: \.self) { option in
                    Text("\(option)").tag(option)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 160, height: 150)
            .accessibilityIdentifier("agePicker")

            Spacer()

            Text("age in years")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Spacing.large)
    }
}

#Preview("age") {
    @Previewable @State var selectedAge: Int = 21
    UIWheelAgePlain(value: $selectedAge)
}
