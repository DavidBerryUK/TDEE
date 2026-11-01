//
//  UIWheelWeightPlain.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: a wheel is intentional — a wheel is best for ordered numeric values, not a
// dropdown. DO NOT switch to `.pickerStyle(.menu)` and DO NOT remove the unit-conversion logic below;
// it is load-bearing.
//
// This is the PLAIN control: the original native SwiftUI `.pickerStyle(.wheel)` (its `develop` form),
// undressed. A parent (`SectionEditorWeight` / `WeightNewSectionView`) shows it for every theme that
// does not opt into picker colours, so it must stay visually identical to the pre-theming control — a
// native wheel at the section's natural width, NOT a width-unbounded `UIPickerView`.
//
// The THEMED sibling (`UIWheelWeightThemed`) is the only place a theme dresses the wheel: it passes
// `forceAppearance: true` so each wheel renders as a `UIPickerView` (`UIThemedWheelPicker`) whose
// appearance is forced to light from the theme's `pickerColorScheme`, and it insets each wheel into its
// own rounded panel via `.pickerPanel(background:width:)` (`pickerBackground` / `pickerPanelWidth`, nil
// for non-opting themes). A native `.pickerStyle(.wheel)`'s digits can't be coloured via `foregroundStyle`
// or a wrapper's `.preferredColorScheme` — so the appearance must be forced on the `UIPickerView`
// itself; only the themed path uses `UIThemedWheelPicker`.
//
// Multi-unit picker (kg / pounds / stones+pounds); per-wheel panels + caption offsets are theme-driven and
// nil-default, so a non-opting theme is unchanged. The compound unit (stones & pounds) reuses the shared
// `pickerFeetLabelOffsetX` / `pickerFeetInchesLabelOffsetX` / `pickerWheelSpacing` knobs (documented as
// shared for both compound units). Renamed from `UIWheelPickerWeightView` as part of the story-023
// Themed/Plain split.

import SwiftUI

struct UIWheelWeightPlain: View {

    //
    // Source of truth: always kilograms
    //
    @Binding var value: Double
    @Binding var unitOfMeasure: OptionWeight

    // The theme-driven dressing, threaded in by UIWheelWeightThemed; all nil/false for the plain call, so
    // a non-opting theme is undressed. Mirrors UIWheelHeightPlain: per-wheel panel + caption offsets; the
    // compound unit (stones & pounds) reuses the shared picker* knobs.
    var pickerBackground: Color? = nil
    var pickerPanelWidth: CGFloat? = nil
    var pickerLabelOffsetX: CGFloat? = nil
    var pickerFeetLabelOffsetX: CGFloat? = nil
    var pickerFeetInchesLabelOffsetX: CGFloat? = nil
    var pickerWheelSpacing: CGFloat? = nil
    /// Forces each wheel's digit colour dark via a forced light appearance. A native
    /// `.pickerStyle(.wheel)` ignores `foregroundStyle` and a wrapper's `.preferredColorScheme` does not
    /// reach its digit colour, so the themed sibling passes `true` to render each wheel as a `UIPickerView`
    /// (`UIThemedWheelPicker`) whose appearance is forced from the theme's `pickerColorScheme`. `false`
    /// (the default — every non-opting theme) keeps the original native wheel.
    var forceAppearance: Bool = false

    // Picker state
    @State private var valueKg: Int = 0
    @State private var valuePounds: Int = 0
    @State private var valueStones: Int = 0
    @State private var valueStonePounds: Int = 0

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

    /// Animation duration for weight picker (0.30 seconds)
    let animDuration : CGFloat = 0.30

    // Options
    var optionsKg: [Int] = Array(0...250)
    var optionsPounds: [Int] = Array(0...550)
    var optionsStones: [Int] = Array(0...40)
    var optionsStonePounds: [Int] = Array(0...13)

    var body: some View {

        let showIsKg = unitOfMeasure == .kilograms
        let showIsPounds = unitOfMeasure == .pounds
        let showIsStonesAndPounds = unitOfMeasure == .stonesAndPounds

        return ZStack {

            // KG
            UIPickerKgView
                .opacity(showIsKg ? animOpacitySolid : animOpacityClear)
                .offset(y: showIsKg ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showIsKg ? animZoomFull : animZoomOut)
                .allowsHitTesting(showIsKg)

            // Pounds
            UIPickerPoundsView
                .opacity(showIsPounds ? animOpacitySolid : animOpacityClear)
                .offset(y: showIsPounds ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showIsPounds ? animZoomFull : animZoomOut)
                .allowsHitTesting(showIsPounds)

            // Stones + Pounds
            UIPickerStonesAndPoundsView
                .opacity(showIsStonesAndPounds ? animOpacitySolid : animOpacityClear)
                .offset(y: showIsStonesAndPounds ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showIsStonesAndPounds ? animZoomFull : animZoomOut)
                .allowsHitTesting(showIsStonesAndPounds)
        }
        .frame(height: 150)
        .animation(.easeInOut(duration: animDuration), value: unitOfMeasure)
        .onAppear {
            initialiseValues()
        }
        .onChange(of: unitOfMeasure) { oldMeasure, _ in
            syncStateFromPreviousUnit(oldMeasure: oldMeasure)
        }
        .onChange(of: valueKg) { _, newValue in
            convertFromKgToValue(kg: newValue)
        }
        .onChange(of: valuePounds) { _, newValue in
            convertFromPoundsToValue(pounds: newValue)
        }
        .onChange(of: valueStones) { _, newValue in
            convertFromStonesAndPoundsToValue(stones: newValue, pounds: valueStonePounds)
        }
        .onChange(of: valueStonePounds) { _, newValue in
            convertFromStonesAndPoundsToValue(stones: valueStones, pounds: newValue)
        }
    }
}

private extension UIWheelWeightPlain {

    func initialiseValues() {
        valueKg = Int(round( value))
        let totalPounds = WeightConvertor.toPounds(value)
        valuePounds = totalPounds
        valueStones = totalPounds / 14
        valueStonePounds = totalPounds % 14
    }

    func syncStateFromPreviousUnit(oldMeasure: OptionWeight) {

        switch oldMeasure
        {
        case .kilograms:
            let totalPounds = WeightConvertor.toPounds( valueKg)
            valuePounds = totalPounds
            valueStones = totalPounds / 14
            valueStonePounds = totalPounds % 14
            break

        case .pounds:
            let totalPounds = valuePounds
            valueKg = WeightConvertor.toKilogramsInt(pounds: totalPounds)
            valueStones = totalPounds / 14
            valueStonePounds = totalPounds % 14
            break

        case .stonesAndPounds:
            let totalPounds = valueStones * 14 + valueStonePounds
            valueKg = WeightConvertor.toKilogramsInt(pounds: totalPounds)
            valuePounds = totalPounds
            break
        }
    }

    func convertFromKgToValue(kg: Int) {
        guard unitOfMeasure == .kilograms else { return }
        value = Double(kg)
    }

    func convertFromPoundsToValue(pounds: Int) {
        guard unitOfMeasure == .pounds else { return }
        value = WeightConvertor.toKilograms(pounds: pounds)
    }

    func convertFromStonesAndPoundsToValue(stones: Int, pounds: Int) {
        guard unitOfMeasure == .stonesAndPounds else { return }
        let totalPounds = (stones * 14) + pounds
        value = WeightConvertor.toKilograms(pounds: totalPounds)
    }
}

private extension UIWheelWeightPlain {

    // The single wheel, shared by every builder: a `UIPickerView` with a forced appearance (themed, so
    // the digits read dark on the light panel) when `forceAppearance`, else the original native wheel.
    // Keeping the renderer choice in one place means the cross-fade / sync logic has a single copy — the
    // plain and themed controls differ only in this renderer.
    @ViewBuilder
    private func weightWheel(_ label: String, selection: Binding<Int>, rows: [Int]) -> some View {
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

    var UIPickerKgView: some View {
        ZStack {
            weightWheel("Kg", selection: $valueKg, rows: optionsKg)
                .frame(height: 150)
                .accessibilityIdentifier("weightKgWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            UITextPickerLabel("kg")
                .offset(x: pickerLabelOffsetX ?? 36)
        }
    }

    var UIPickerPoundsView: some View {
        ZStack {
            weightWheel("Pounds", selection: $valuePounds, rows: optionsPounds)
                .frame(height: 150)
                .accessibilityIdentifier("weightPoundsWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            UITextPickerLabel("pounds")
                .offset(x: pickerLabelOffsetX ?? 50)
        }
    }

    @ViewBuilder
    var UIPickerStonesAndPoundsView : some View {
        // A themed gap (`pickerWheelSpacing`) opens the space between the two wheels so a unit caption
        // can sit between them; with no spacing the group uses its natural spacing, as before.
        if let spacing = pickerWheelSpacing {
            HStack(spacing: spacing) { stonesAndPoundsWheels }
        } else {
            HStack { stonesAndPoundsWheels }
        }
    }

    @ViewBuilder
    private var stonesAndPoundsWheels: some View {
        ZStack{
            weightWheel("Stones", selection: $valueStones, rows: optionsStones)
                .frame(height: 150)
                .accessibilityIdentifier("weightStonesWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            // The compound unit's first caption reuses the shared `pickerFeetLabelOffsetX` knob.
            UITextPickerLabel("stones")
                .offset(x: pickerFeetLabelOffsetX ?? pickerLabelOffsetX ?? 36)
        }

        ZStack{
            weightWheel("Pounds", selection: $valueStonePounds, rows: optionsStonePounds)
                .frame(height: 150)
                .accessibilityIdentifier("weightStonesPoundsWheel")
                .pickerPanel(background: pickerBackground, width: pickerPanelWidth)
            // Rightmost wheel of the compound: the "pounds" caption sits to the RIGHT of its wheel, like
            // every other unit caption. Reuses the shared `pickerFeetInchesLabelOffsetX` knob.
            UITextPickerLabel("pounds")
                .offset(x: pickerFeetInchesLabelOffsetX ?? pickerLabelOffsetX ?? 36)
        }
    }
}



#Preview("kg") {
    @Previewable @State var value: Double = 21
    @Previewable @State var unitOfMeasure : OptionWeight = OptionWeight.kilograms
    UIWheelWeightPlain(value: $value, unitOfMeasure: $unitOfMeasure)
}

#Preview("Pounds") {
    @Previewable @State var value: Double = 21
    @Previewable @State var unitOfMeasure : OptionWeight = OptionWeight.pounds
    UIWheelWeightPlain(value: $value, unitOfMeasure: $unitOfMeasure)
}

#Preview("Stones and Pounds") {
    @Previewable @State var weightInKg: Double = 21
    @Previewable @State var unitOfMeasure : OptionWeight = OptionWeight.stonesAndPounds
    UIWheelWeightPlain(value: $weightInKg, unitOfMeasure: $unitOfMeasure)
}
