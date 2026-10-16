//
//  WatchGenderView.swift
//  TDEE Watch
//
//

import SwiftUI

struct WatchGenderView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        WheelScreen(title: "Gender") {
            Picker("Gender", selection: $profile.gender) {
                ForEach(Gender.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
        }
    }
}

#Preview() {
    WatchGenderView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
