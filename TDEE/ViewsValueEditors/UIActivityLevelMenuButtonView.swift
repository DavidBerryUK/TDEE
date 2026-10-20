//
//  UIActivityLevelMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New activity-level control (story 023, input #9) for compact and regular sizes.
///
/// A neutral `Menu` labelled "Activity Level" that lists every `ActivityLevel` case and rebinds
/// `model.activityLevel` — the Classic wheel picker's 9-case categorical pick, surfaced as a dropdown.
/// It mirrors the neutral UoM menu button (`UIWeightUomMenuButtonView` / `UIHeightUomMenuButtonView`)
/// and replaces `UIWheelPickerActivityLevelView` without touching it — see `ActivityLevelNewSectionView`.
struct UIActivityLevelMenuButtonView: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Menu {
            ForEach(ActivityLevel.allCases, id: \.self) { level in
                Button {
                    model.activityLevel = level
                } label: {
                    Text(level.displayName)
                }
            }
        } label: {
            Text("Activity Level")
        }
        .accessibilityIdentifier("activityLevelMenu")
    }
}

#Preview {
    UIActivityLevelMenuButtonView(model: ProfileViewModel())
}
