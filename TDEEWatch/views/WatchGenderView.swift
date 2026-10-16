//
//  WatchGenderView.swift
//  TDEE Watch
//

import SwiftUI

/// Two options, so a list with a tick is quicker than a wheel.
struct WatchGenderView: View {
    @Bindable var profile: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(Gender.allCases, id: \.self) { gender in
            Button {
                profile.gender = gender
                dismiss()
            } label: {
                HStack {
                    Text(gender.displayName)
                    Spacer()
                    if gender == profile.gender {
                        Image(systemName: "checkmark")
                            .foregroundStyle(WatchPalette.selection)
                    }
                }
            }
            .accessibilityAddTraits(gender == profile.gender ? .isSelected : [])
        }
        .navigationTitle("Gender")
    }
}

#Preview() {
    WatchGenderView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
