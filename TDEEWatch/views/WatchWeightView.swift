//
//  WatchWeightView.swift
//  TDEE Watch
//
//

import SwiftUI

struct WatchWeightView: View {
    @Bindable var profile: ProfileViewModel

    private var kilograms: Binding<Int> {
        Binding(get: { Int(profile.weight.rounded()) }, set: { profile.weight = Double($0) })
    }

    var body: some View {
        WheelScreen(title: "Weight") {
            Picker("Weight in kilograms", selection: kilograms) {
                ForEach(WatchRanges.weightKg, id: \.self) { Text("\($0) kg").tag($0) }
            }
        }
        // A new profile has no weight: start the wheel near a typical value
        .onAppear {
            if profile.weight == 0 { profile.weight = WatchRanges.startingWeightKg }
        }
    }
}

#Preview() {
    WatchWeightView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
