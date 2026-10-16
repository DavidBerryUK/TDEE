//
//  WatchHeightView.swift
//  TDEE Watch
//
//

import SwiftUI

struct WatchHeightView: View {
    @Bindable var profile: ProfileViewModel

    private var centimetres: Binding<Int> {
        Binding(get: { Int(profile.height.rounded()) }, set: { profile.height = Double($0) })
    }

    var body: some View {
        WheelScreen(title: "Height") {
            Picker("Height in centimetres", selection: centimetres) {
                ForEach(WatchRanges.heightCm, id: \.self) { Text("\($0) cm").tag($0) }
            }
        }
    }
}

#Preview() {
    WatchHeightView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
