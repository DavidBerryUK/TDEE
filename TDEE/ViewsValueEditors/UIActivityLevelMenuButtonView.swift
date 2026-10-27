//
//  UIActivityLevelMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New activity-level control (story 023, input #9) for compact and regular sizes.
///
/// A `Menu` whose label is the current level's full name (`Sedentary` / `Light Exercise` /
/// `Moderate Exercise` / `Heavy Exercise` / `Athlete`) plus a selector chevron, that rebinds
/// `model.activityLevel` — the Classic wheel picker's categorical pick, surfaced as a dropdown. The
/// full name and chevron make the control read as a value picker, the discoverability fix for the old
/// neutral "Activity Level" label (Decision 10), mirroring the UoM switchers
/// (`UIWeightUomMenuButtonView` / `UIHeightUomMenuButtonView`), and replacing
/// `UIWheelPickerActivityLevelView` without touching it — see `ActivityLevelNewSectionView`.
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
            // Full name + a selector chevron, so the control reads as a value picker.
            HStack(spacing: 4) {
                Text(model.activityLevel.displayName)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("activityLevelMenu")
    }
}

#Preview {
    UIActivityLevelMenuButtonView(model: ProfileViewModel())
}
