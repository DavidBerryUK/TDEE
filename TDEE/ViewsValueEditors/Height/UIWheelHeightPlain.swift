//
//  UIWheelHeightPlain.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: the .pickerStyle(.wheel) is intentional — a wheel is best for ordered numeric
// values, not a dropdown. This is the PLAIN height wheel: the raw multi-unit SwiftUI
// .pickerStyle(.wheel) with no theme dressing. Its themed sibling (themed panel + forced appearance)
// is UIWheelHeightThemed; a parent shows one or the other based on the active theme.
// This is a multi-wheel picker (cm / inches / feet+inches) with load-bearing unit-conversion logic —
// do not change .wheel to .menu and do not remove that logic. Renamed from UIWheelPickerHeightView
// as part of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelHeightPlain: View {

    @Binding var value: Double
    @Binding var unitOfMeasure : OptionLength

    @State private  var valueCm: Int = 0
    @State private  var valueInches: Int = 0
    @State private  var valueFeet: Int = 0
    @State private  var valueFeetInches: Int = 0

    // Animation Constants
    /// Offset animation value (24 points)
    let animOffsetOffset : CGFloat = 24

    /// No offset animation value (0 points)
    let animOffsetNone : CGFloat = 0

    /// Zoom out animation scale (0.98)
    let animZoomOut : CGFloat = 0.98

    /// Full zoom animation scale (1.00)
    let animZoomFull : CGFloat = 1.00

    /// Clear opacity value (0.0)
    let animOpacityClear : CGFloat = 0

    /// Solid opacity value (1.0)
    let animOpacitySolid : CGFloat = 1

    /// Animation duration for height picker (0.30 seconds)
    let animDuration : CGFloat = 0.30

    // Options
    var optionsCm: [Int] = Array(0...272)
    var optionsInches: [Int] = Array(0...107)
    var optionsFeet: [Int] = Array(0...8)
    var optionsFeetInches: [Int] = Array(0...11)

    var body: some View {

        let showCm : Bool = (unitOfMeasure == OptionLength.centimeters)
        let showInches : Bool = (unitOfMeasure == OptionLength.inches)
        let showFeetAndInches : Bool = (unitOfMeasure == OptionLength.feetAndInches)

        ZStack{

            UIPickerViewCentimeters
                .opacity(showCm ? animOpacitySolid : animOpacityClear)
                .offset(y: showCm ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showCm ? animZoomFull : animZoomOut)
                .allowsHitTesting(showCm)

            UIPickerViewInches
                .opacity(showInches ? animOpacitySolid : animOpacityClear)
                .offset(y: showInches ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showInches ? animZoomFull : animZoomOut)
                .allowsHitTesting(showInches)

            UIPickerViewFeetAndInches
                .opacity(showFeetAndInches ? animOpacitySolid : animOpacityClear)
                .offset(y: showFeetAndInches ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showFeetAndInches ? animZoomFull : animZoomOut)
                .allowsHitTesting(showFeetAndInches)
        }
        .frame(height: 150)
        .animation(.easeInOut(duration: animDuration), value: unitOfMeasure)
        .onAppear {
            initialiseValues()
        }
        .onChange(of: unitOfMeasure) { oldMeasure, _ in
            syncStateFromPreviousUnit(oldMeasure: oldMeasure)
        }
        .onChange(of: valueCm) { _, newValue in
            convertFromCmToValue(cm: newValue)
        }
        .onChange(of: valueInches) { _, newValue in
            convertFromInchesToValue(inches: newValue)
        }
        .onChange(of: valueFeet) { _, newValue in
            convertFromFeetAndInchesToValue(feet: newValue, inches: valueFeetInches)
        }
        .onChange(of: valueFeetInches) { _, newValue in
            convertFromFeetAndInchesToValue(feet: valueFeet, inches: newValue)
        }
    }
}

private extension UIWheelHeightPlain {

    func initialiseValues() {
        valueCm = Int(round( value))
        let totalInches = LengthConverter.toInches(valueCm)
        valueInches = totalInches
        valueFeet = totalInches / 12
        valueFeetInches = totalInches % 12
    }

    func syncStateFromPreviousUnit(oldMeasure: OptionLength) {

        switch oldMeasure
        {
        case .centimeters:
            let totalInches = LengthConverter.toInches(valueCm)
            valueInches = totalInches
            valueFeet = totalInches / 12
            valueFeetInches = totalInches % 12
            break

        case .inches:
            let totalInches = valueInches
            valueCm = LengthConverter.toCentimetersInt(totalInches)
            valueFeet = totalInches / 12
            valueFeetInches = totalInches % 12
            break

        case .feetAndInches:
            let totalInches = valueFeet * 12 + valueFeetInches
            valueCm = LengthConverter.toCentimetersInt(totalInches)
            valueInches = totalInches
            break
        }
    }

    func convertFromCmToValue(cm: Int) {
        guard unitOfMeasure == .centimeters else { return }
        value = Double(cm)
    }

    func convertFromInchesToValue(inches: Int) {
        guard unitOfMeasure == .inches else { return }
        value = LengthConverter.toCentimeters(inches)
    }

    func convertFromFeetAndInchesToValue(feet: Int, inches: Int) {
        guard unitOfMeasure == .feetAndInches else { return }
        let totalInches = (feet * 12) + inches
        value = LengthConverter.toCentimeters(totalInches)
    }
}

private extension UIWheelHeightPlain {

    var UIPickerViewCentimeters : some View {
        ZStack{
            Picker("Cm", selection: $valueCm) {
                ForEach(optionsCm, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .accessibilityIdentifier("heightCmWheel")
            UITextPickerLabel("centimeters")
                .offset(x: 60)
        }
    }

    var UIPickerViewInches : some View {
        ZStack{

            Picker("Inches", selection: $valueInches) {
                ForEach(optionsInches, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .accessibilityIdentifier("heightInchesWheel")
            UITextPickerLabel("inches")
                .offset(x: 40)
        }
    }

    var UIPickerViewFeetAndInches : some View {
        HStack{
            ZStack{
                Picker("feet", selection: $valueFeet) {
                    ForEach(optionsFeet, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .accessibilityIdentifier("heightFeetWheel")
                UITextPickerLabel("feet")
                    .offset(x: 36)
            }

            ZStack{
                Picker("Inches", selection: $valueFeetInches) {
                    ForEach(optionsFeetInches, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .accessibilityIdentifier("heightFeetInchesWheel")
                UITextPickerLabel("inches")
                    .offset(x: 36)
            }
        }
    }
}

#Preview("Centimeters") {
    @Previewable @State var selectedHeight: Double = 200
    @Previewable @State var unitOfMeasure : OptionLength = OptionLength.centimeters
    UIWheelHeightPlain(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}

#Preview("Inches") {
    @Previewable @State var selectedHeight: Double = 200
    @Previewable @State var unitOfMeasure : OptionLength = OptionLength.inches
    UIWheelHeightPlain(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}

#Preview("Feet and Inches") {
    @Previewable @State var selectedHeight: Double = 200
    @Previewable @State var unitOfMeasure : OptionLength = OptionLength.feetAndInches
    UIWheelHeightPlain(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}
