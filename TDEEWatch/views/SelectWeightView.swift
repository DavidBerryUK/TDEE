//
//  SelectWeightView.swift
//  TDEE Watch
//
//

import SwiftUI

/// Watch equivalent of the iPhone's `UISegmentUomWeightView`: lets the user pick the weight
/// unit of measure (kg / pounds / stones & pounds). Only the display unit flips — `profile.weight`
/// stays in kilograms as the source of truth, so `WatchWeightView` converts the value on switch.
struct SelectWeightView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        Picker("Weight Unit", selection: $profile.weightUom) {
            ForEach(OptionWeight.allCases, id: \.self) { unit in
                Text(unit.displayName)
            }
        }
        // The navigation bar already shows the title; hide the picker's own label so it isn't shown twice.
        .labelsHidden()
        .navigationTitle("Weight Unit")
    }
}

#Preview() {
    SelectWeightView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
