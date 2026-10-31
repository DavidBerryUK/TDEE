//
//  UIWheelHeightPlain.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: a wheel is intentional — a wheel is best for ordered numeric values, not a
// dropdown. Each wheel renders through `UIThemedWheelPicker` (a `UIPickerView` a theme can dress, see
// its file) rather than a raw SwiftUI `.pickerStyle(.wheel)`: the native wheel ignores `foregroundStyle`
// and a forced light appearance loses to the app's dark scheme, so its digit colour couldn't be themed —
// the height wheels now borrow the age picker's themed wheel to get the theme's digit colour. It is
// still a wheel, not a menu. Each wheel insets into its OWN rounded panel when a `pickerBackground` is
// supplied (nil by default, so a non-theming theme sees no panel — identical to before); the themed
// sibling (UIWheelHeightThemed) feeds the active palette's colours. This is a multi-wheel picker
// (cm / inches / feet+inches) with load-bearing unit-conversion logic — do not switch to `.menu` and do
// not remove that logic. Renamed from UIWheelPickerHeightView as part of the story-023 Themed/Plain
// split.

import SwiftUI

struct UIWheelHeightPlain: View {

    @Binding var value: Double
    @Binding var unitOfMeasure : OptionLength

    /// The panel colour each wheel is inset into so its highlighted row reads against a distinct
    /// field. `nil` (the default — every theme that doesn't opt in) leaves each wheel panel-less,
    /// exactly as before; the themed sibling passes the active palette's `pickerBackground`.
    var pickerBackground: Color? = nil

    /// The panel's fixed width; `nil` keeps each wheel at its natural width. The themed sibling passes
    /// the active palette's `pickerPanelWidth`.
    var pickerPanelWidth: CGFloat? = nil
    /// The unit caption's x-offset; `nil` keeps each wheel's own caption position. The themed sibling
    /// passes the active palette's `pickerLabelOffsetX`.
    var pickerLabelOffsetX: CGFloat? = nil
    /// The feet wheel's caption offset within feet & inches; `nil` falls back to `pickerLabelOffsetX`
    /// (then the wheel's own position), so a theme that sets only the shared offset is unchanged.
    var pickerFeetLabelOffsetX: CGFloat? = nil
    /// The feet-&-inches wheel's ("inches") caption offset; `nil` falls back to `pickerLabelOffsetX`.
    var pickerFeetInchesLabelOffsetX: CGFloat? = nil
    /// The gap between the two wheels of a compound unit; `nil` uses the group's natural spacing. The
    /// themed sibling passes the active palette's `pickerWheelSpacing`.
    var pickerWheelSpacing: CGFloat? = nil

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
            UIThemedWheelPicker(rows: optionsCm, selection: $valueCm)
                .frame(height: 150)
                .accessibilityIdentifier("heightCmWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            UITextPickerLabel("centimeters")
                .offset(x: pickerLabelOffsetX ?? 60)
        }
    }

    var UIPickerViewInches : some View {
        ZStack{

            UIThemedWheelPicker(rows: optionsInches, selection: $valueInches)
                .frame(height: 150)
                .accessibilityIdentifier("heightInchesWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            UITextPickerLabel("inches")
                .offset(x: pickerLabelOffsetX ?? 40)
        }
    }

    @ViewBuilder
    var UIPickerViewFeetAndInches : some View {
        // A themed gap (`pickerWheelSpacing`) opens the space between the two wheels so a unit caption
        // can sit between them; with no spacing the group uses its natural spacing, as before.
        if let spacing = pickerWheelSpacing {
            HStack(spacing: spacing) { feetAndInchesWheels }
        } else {
            HStack { feetAndInchesWheels }
        }
    }

    @ViewBuilder
    private var feetAndInchesWheels: some View {
        ZStack{
            UIThemedWheelPicker(rows: optionsFeet, selection: $valueFeet)
                .frame(height: 150)
                .accessibilityIdentifier("heightFeetWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            UITextPickerLabel("feet")
                .offset(x: pickerFeetLabelOffsetX ?? pickerLabelOffsetX ?? 36)
        }

        ZStack{
            UIThemedWheelPicker(rows: optionsFeetInches, selection: $valueFeetInches)
                .frame(height: 150)
                .accessibilityIdentifier("heightFeetInchesWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            // Rightmost wheel: the "inches" caption sits to the RIGHT of its wheel, like every other
            // unit caption. The gap (`pickerWheelSpacing`) and the panel width keep the whole group —
            // two panels plus two right-pointing captions — inside the screen.
            UITextPickerLabel("inches")
                .offset(x: pickerFeetInchesLabelOffsetX ?? pickerLabelOffsetX ?? 36)
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
