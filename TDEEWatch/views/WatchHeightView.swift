//
//  WatchHeightView.swift
//  TDEE Watch
//
//

import SwiftUI

/// Watch equivalent of the iPhone's `UIWheelPickerHeightView`: shows a wheel in the currently
/// selected unit (cm / inches / feet & inches). `profile.height` is always the source of truth in
/// centimetres; the wheels below convert through `LengthConverter` so the displayed value follows
/// the chosen unit.
struct WatchHeightView: View {
    @Bindable var profile: ProfileViewModel

    // Display state, one per unit. Kept in sync with `profile.height` (centimetres).
    @State private var valueCm = 0
    @State private var valueInches = 0
    @State private var valueFeet = 0
    @State private var valueFeetInches = 0

    var body: some View {
        WheelScreen(title: "Height", showChangeUnit: true,
                    changeUnitDestination: { SelectHeightView(profile: profile) }) {
            switch profile.heightUom {
            case .centimeters:
                Picker("Height in centimetres", selection: $valueCm) {
                    ForEach(WatchRanges.heightCm, id: \.self) { Text("\($0) cm").tag($0) }
                }
            case .inches:
                Picker("Height in inches", selection: $valueInches) {
                    ForEach(WatchRanges.heightInches, id: \.self) { Text("\($0) in").tag($0) }
                }
            case .feetAndInches:
                HStack(spacing: 0) {
                    Picker("Feet", selection: $valueFeet) {
                        ForEach(WatchRanges.heightFeet, id: \.self) { Text("\($0) ft").tag($0) }
                    }
                    Picker("Inches", selection: $valueFeetInches) {
                        ForEach(WatchRanges.heightFeetInches, id: \.self) { Text("\($0) in").tag($0) }
                    }
                }
            }
        }
        // A new profile has no height: start the wheel near a typical value.
        .onAppear {
            if profile.height == 0 { profile.height = WatchRanges.startingHeightCm }
            syncFromCentimeters()
        }
        // Switching the unit re-derives every wheel from the stored centimetres.
        .onChange(of: profile.heightUom) { _, _ in syncFromCentimeters() }
        .onChange(of: valueCm) { _, cm in
            guard profile.heightUom == .centimeters else { return }
            profile.height = Double(cm)
        }
        .onChange(of: valueInches) { _, inches in
            guard profile.heightUom == .inches else { return }
            profile.height = LengthConverter.toCentimeters(inches)
        }
        .onChange(of: valueFeet) { _, _ in
            guard profile.heightUom == .feetAndInches else { return }
            profile.height = LengthConverter.toCentimeters(valueFeet * 12 + valueFeetInches)
        }
        .onChange(of: valueFeetInches) { _, _ in
            guard profile.heightUom == .feetAndInches else { return }
            profile.height = LengthConverter.toCentimeters(valueFeet * 12 + valueFeetInches)
        }
    }

    /// Re-derive every wheel's display value from the stored centimetres.
    private func syncFromCentimeters() {
        valueCm = Int(profile.height.rounded())
        let inches = LengthConverter.toInches(valueCm)
        valueInches = inches
        valueFeet = inches / 12
        valueFeetInches = inches % 12
    }
}

#Preview() {
    WatchHeightView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
