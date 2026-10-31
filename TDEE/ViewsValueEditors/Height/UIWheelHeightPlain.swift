//
//  UIWheelHeightPlain.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: a wheel is intentional — a wheel is best for ordered numeric values, not a
// dropdown. DO NOT switch to `.pickerStyle(.menu)` and DO NOT remove the unit-conversion logic below;
// it is load-bearing. APPROVAL REQUIRED BEFORE ANY MODIFICATIONS to the wheel/segment pairing.
//
// This is the PLAIN control: the original native SwiftUI `.pickerStyle(.wheel)` (its `develop` form),
// undressed. A parent (`SectionEditorHeight` / `HeightNewSectionView`) shows it for every theme that
// does not opt into picker colours, so it must stay visually identical to the pre-theming control — a
// native wheel at the section's natural width, NOT a width-unbounded `UIPickerView`.
//
// The THEMED sibling (`UIWheelHeightThemed`) is the only place a theme dresses the wheel: it passes
// `forceAppearance: true` so each wheel renders as a `UIPickerView` (`UIThemedWheelPicker`) whose
// appearance is forced to light from the theme's `pickerColorScheme`, and it insets each wheel into its
// own rounded panel via `.pickerPanel(background:width:)` (`pickerBackground` / `pickerPanelWidth`, nil
// for non-opting themes). A native `.pickerStyle(.wheel)`'s digits can't be coloured via `foregroundStyle`
// or a wrapper's `.preferredColorScheme` — that's why the revert's plain path lost its dark digits — so the
// appearance must be forced on the `UIPickerView` itself; only the themed path uses `UIThemedWheelPicker`.
//
// Multi-unit picker (cm / inches / feet+inches); per-wheel panels + caption offsets are theme-driven and
// nil-default, so a non-opting theme is unchanged. Renamed from `UIWheelPickerHeightView` as part of the
// story-023 Themed/Plain split; the "all wheels via `UIThemedWheelPicker`" route was reverted 2026-10-31
// because it made the plain control a width-unbounded `UIPickerView` that filled the section on every
// non-Orange theme.

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
    /// Forces each wheel's digit colour dark via a forced light appearance. A native
    /// `.pickerStyle(.wheel)` ignores `foregroundStyle` and a wrapper's `.preferredColorScheme` does not
    /// reach its digit colour, so the themed sibling passes `true` to render each wheel as a `UIPickerView`
    /// (`UIThemedWheelPicker`) whose appearance is forced from the theme's `pickerColorScheme`. `false`
    /// (the default — every non-opting theme) keeps the original native wheel.
    var forceAppearance: Bool = false

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

    // The single wheel, shared by every builder: a `UIPickerView` with a forced appearance (themed, so
    // the digits read dark on the light panel) when `forceAppearance`, else the original native wheel.
    // Keeping the renderer choice in one place means the cross-fade / sync logic has a single copy — the
    // plain and themed controls differ only in this renderer.
    @ViewBuilder
    private func heightWheel(_ label: String, selection: Binding<Int>, rows: [Int]) -> some View {
        if forceAppearance {
            UIThemedWheelPicker(rows: rows, selection: selection)
        } else {
            Picker(label, selection: selection) {
                ForEach(rows, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
        }
    }

    var UIPickerViewCentimeters : some View {
        ZStack{
            heightWheel("Cm", selection: $valueCm, rows: optionsCm)
                .frame(height: 150)
                .accessibilityIdentifier("heightCmWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            UITextPickerLabel("centimeters")
                .offset(x: pickerLabelOffsetX ?? 60)
        }
    }

    var UIPickerViewInches : some View {
        ZStack{

            heightWheel("Inches", selection: $valueInches, rows: optionsInches)
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
            heightWheel("feet", selection: $valueFeet, rows: optionsFeet)
                .frame(height: 150)
                .accessibilityIdentifier("heightFeetWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            UITextPickerLabel("feet")
                .offset(x: pickerFeetLabelOffsetX ?? pickerLabelOffsetX ?? 36)
        }

        ZStack{
            heightWheel("Inches", selection: $valueFeetInches, rows: optionsFeetInches)
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
