//
//  GenderNewSectionView.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import SwiftUI
import Observation

/// The New gender input section (story 023, input #1).
///
/// A layout redesign of the gender control: there is no expand/collapse panel — the segmented
/// control lives inline in the section header and shows the current pick directly. The control
/// itself is reused verbatim from `UISegmentGenderView` (its segmented style and both options are
/// locked), so only the *placement* changes, not the control — and `UISegmentGenderView` is left
/// untouched.
///
/// `MainSectionProfileInput` selects this via `InputStyleManager` when gender's style is `.new`.
struct GenderNewSectionView: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // At accessibility sizes the control gets its own full-width line so neither the title
        // nor the segments are squeezed; otherwise it sits in the header row.
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? Spacing.small : 0) {
            HStack {
                UIIcon(icon: .gender, style: .coloredBackgroundSolid)
                Text("Gender")
                    .font(.headline)
                // Guaranteed breathing room between the label and the control: a minimum gap that
                // still lets the control trail to the edge on wide screens.
                Spacer(minLength: Spacing.large)
                if !dynamicTypeSize.isAccessibilitySize {
                    UISegmentGenderView(option: $model.gender)
                }
            }
            if dynamicTypeSize.isAccessibilitySize {
                UISegmentGenderView(option: $model.gender)
            }
        }
        .padding(Spacing.large)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    GenderNewSectionView(model: ProfileViewModel())
}
