//
//  UIWheelBodyFatPlain.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: the .pickerStyle(.wheel) is intentional — a wheel is best for ordered numeric
// values, not a dropdown. This is the PLAIN body-fat-percentage wheel: the raw integer + decimal
// SwiftUI .pickerStyle(.wheel) pair with no theme dressing. Its themed sibling (themed panel + forced
// appearance) is UIWheelBodyFatThemed; a parent shows one or the other based on the active theme.
// Renamed from UIWheelPickerBodyFatView as part of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelBodyFatPlain: View {
    @Environment(\.palette) private var palette

    @Binding var value: Double

    @State private var valueInteger: Int = 0
    @State private var valueDecimal: Int = 0

    var optionsInteger: [Int] = Array(0...99)
    var optionsDecimal: [Int] = Array(0...9)

    var body: some View {
        HStack(spacing: 4) {

            Picker("Body fat percentage", selection: $valueInteger) {
                ForEach(optionsInteger, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 110)   // key change
            .accessibilityIdentifier("bodyFatPicker")

            Text(".")
                .foregroundStyle(palette.textSecondary)
                .fontWeight(.black)

            Picker("Body fat decimal", selection: $valueDecimal) {
                ForEach(optionsDecimal, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 110)   // key change
            .accessibilityIdentifier("bodyFatDecimalPicker")

            Text("%")
                .foregroundStyle(palette.textSecondary)
                .padding(.leading, 2) // keeps it tight to it
        }
        .padding(.horizontal, 16) // page padding
        .onChange(of: valueInteger) {
            updateValue()
        }
        .onChange(of: valueDecimal) {
            updateValue()
        }
        .onAppear {
            // initialise from binding
            valueInteger = Int(value)
            valueDecimal = Int((value * 10).truncatingRemainder(dividingBy: 10))
        }
    }

    private func updateValue() {
        value = Double(valueInteger) + Double(valueDecimal) / 10.0
    }
}

#Preview() {
    @Previewable @State var bodyFat: Double = 15.7
    UIWheelBodyFatPlain(value: $bodyFat)
}
