//
//  UIWheelPickerBodyFatView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains wheel pickers for body fat percentage (integer + decimal).
// The .pickerStyle(.wheel) is intentional - wheel pickers are best for numeric values.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UIWheelPickerBodyFatView: View {
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
    UIWheelPickerBodyFatView(value: $bodyFat)
}
