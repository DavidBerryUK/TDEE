//
//  SelectHeightView.swift
//  TDEE Watch
//
//

import SwiftUI

/// Watch equivalent of the iPhone's `UISegmentUomLengthView`: lets the user pick the height
/// unit of measure (cm / inches / feet & inches). Only the display unit flips — `profile.height`
/// stays in centimetres as the source of truth, so `WatchHeightView` converts the value on switch.
struct SelectHeightView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        Picker("Height Unit", selection: $profile.heightUom) {
            ForEach(OptionLength.allCases, id: \.self) { unit in
                Text(unit.displayName)
            }
        }
        // The navigation bar already shows the title; hide the picker's own label so it isn't shown twice.
        .labelsHidden()
        .navigationTitle("Height Unit")
    }
}

#Preview() {
    SelectHeightView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
