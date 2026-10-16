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
    var optionsAge: [Int] = Array(16...99)

    var body: some View {
        HStack {
            Picker("age", selection: $value) {
                ForEach(optionsAge, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .accessibilityIdentifier("agePicker")

            Spacer()

            Text("age in years")
                .foregroundStyle(palette.textSecondary)
        }
    }
}

#Preview("age") {
    @Previewable @State var selectedAge: Int = 21
    UIWheelPickerAgeView(value: $selectedAge)
}
