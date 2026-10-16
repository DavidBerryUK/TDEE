//
//  WatchAgeView.swift
//  TDEE Watch
//
//

import SwiftUI

struct WatchAgeView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        WheelScreen(title: "Age") {
            Picker("Age in years", selection: $profile.age) {
                ForEach(WatchRanges.age, id: \.self) { Text("\($0) years").tag($0) }
            }
        }
    }
}

#Preview() {
    WatchAgeView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
