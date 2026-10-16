//
//  WatchActivityLevelView.swift
//  TDEE Watch
//
//

import SwiftUI

struct WatchActivityLevelView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        WheelScreen(title: "Activity") {
            Picker("Activity level", selection: $profile.activityLevel) {
                ForEach(ActivityLevel.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
        }
    }
}

#Preview() {
    WatchActivityLevelView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
