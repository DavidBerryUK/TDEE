//
//  WatchWeightView.swift
//  TDEE Watch
//
//

import SwiftUI

/// Watch equivalent of the iPhone's `UIWheelPickerWeightView`: shows a wheel in the currently
/// selected unit (kg / pounds / stones & pounds). `profile.weight` is always the source of truth
/// in kilograms; the wheels below convert through `WeightConvertor` so the displayed value follows
/// the chosen unit.
struct WatchWeightView: View {
    @Bindable var profile: ProfileViewModel

    // Display state, one per unit. Kept in sync with `profile.weight` (kilograms).
    @State private var valueKg = 0
    @State private var valuePounds = 0
    @State private var valueStones = 0
    @State private var valueStonePounds = 0

    var body: some View {
        WheelScreen(title: "Weight", showChangeUnit: true,
                    changeUnitDestination: { SelectWeightView(profile: profile) }) {
            switch profile.weightUom {
            case .kilograms:
                Picker("Weight in kilograms", selection: $valueKg) {
                    ForEach(WatchRanges.weightKg, id: \.self) { Text("\($0) kg").tag($0) }
                }
            case .pounds:
                Picker("Weight in pounds", selection: $valuePounds) {
                    ForEach(WatchRanges.weightPounds, id: \.self) { Text("\($0) lb").tag($0) }
                }
            case .stonesAndPounds:
                HStack(spacing: 0) {
                    Picker("Stones", selection: $valueStones) {
                        ForEach(WatchRanges.weightStones, id: \.self) { Text("\($0) st").tag($0) }
                    }
                    Picker("Pounds", selection: $valueStonePounds) {
                        ForEach(WatchRanges.weightStonePounds, id: \.self) { Text("\($0) lb").tag($0) }
                    }
                }
            }
        }
        // A new profile has no weight: start the wheel near a typical value.
        .onAppear {
            if profile.weight == 0 { profile.weight = WatchRanges.startingWeightKg }
            syncFromKilograms()
        }
        // Switching the unit re-derives every wheel from the stored kilograms.
        .onChange(of: profile.weightUom) { _, _ in syncFromKilograms() }
        .onChange(of: valueKg) { _, kg in
            guard profile.weightUom == .kilograms else { return }
            profile.weight = Double(kg)
        }
        .onChange(of: valuePounds) { _, pounds in
            guard profile.weightUom == .pounds else { return }
            profile.weight = WeightConvertor.toKilograms(pounds: pounds)
        }
        .onChange(of: valueStones) { _, _ in
            guard profile.weightUom == .stonesAndPounds else { return }
            profile.weight = WeightConvertor.toKilograms(stones: valueStones, pounds: valueStonePounds)
        }
        .onChange(of: valueStonePounds) { _, _ in
            guard profile.weightUom == .stonesAndPounds else { return }
            profile.weight = WeightConvertor.toKilograms(stones: valueStones, pounds: valueStonePounds)
        }
    }

    /// Re-derive every wheel's display value from the stored kilograms.
    private func syncFromKilograms() {
        valueKg = Int(profile.weight.rounded())
        let pounds = WeightConvertor.toPounds(profile.weight)
        valuePounds = pounds
        valueStones = pounds / 14
        valueStonePounds = pounds % 14
    }
}

#Preview() {
    WatchWeightView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
