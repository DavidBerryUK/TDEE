//
//  ActivityLevelNewSectionView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI
import Observation

/// The New activity-level input section (story 023, input #9).
///
/// A layout redesign of the activity-level control, like `GenderNewSectionView`: there is no
/// expand/collapse panel — a neutral `Menu` lives inline in the section header (compact / regular) and
/// drops to its own full-width line at accessibility sizes. It lists every `ActivityLevel` case (9) and
/// rebinds `model.activityLevel`, replacing the Classic wheel picker without touching
/// `UIWheelPickerActivityLevelView` / `SectionEditorActivityLevel` (the Classic path stays untouched).
///
/// Activity level is a categorical pick with no range / zero gate, so — unlike the weight and height
/// passes — this needs no `MetricRanges` entry, no validator, and no `validateForCalculation()` change.
///
/// `MainSectionProfileInput` selects this via `InputStyleManager` when activity level's style is `.new`.
struct ActivityLevelNewSectionView: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // At accessibility sizes the control gets its own full-width line so the title and the menu
        // are not squeezed; otherwise it sits in the header row.
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? Spacing.small : 0) {
            HStack {
                UIIcon(icon: .activityLevel, style: .coloredBackgroundSolid)
                Text("Activity Level")
                    .font(.headline)
                // Guaranteed breathing room between the label and the control: a minimum gap that
                // still lets the control trail to the edge on wide screens.
                Spacer(minLength: Spacing.large)
                if !dynamicTypeSize.isAccessibilitySize {
                    UIActivityLevelMenuButtonView(model: model)
                }
            }
            if dynamicTypeSize.isAccessibilitySize {
                UIActivityLevelMenuButtonView(model: model)
            }
        }
        .padding(Spacing.large)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ActivityLevelNewSectionView(model: ProfileViewModel())
}
