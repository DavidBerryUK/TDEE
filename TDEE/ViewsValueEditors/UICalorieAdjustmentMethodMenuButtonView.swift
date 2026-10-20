//
//  UICalorieAdjustmentMethodMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New calorie-adjustment-method control (story 023, input #10) for compact and regular sizes.
///
/// A neutral `Menu` labelled "Method" that lists every `CalorieAdjustmentMethod` case and rebinds
/// `model.calorieAdjustmentMethod` — the Classic segmented control's 3-case pick (Cut / Maintain / Bulk),
/// surfaced as a dropdown. It mirrors the neutral menu buttons (`UIActivityLevelMenuButtonView` /
/// `UIBodyFatMethodMenuButtonView`) and replaces `UISegmentCalorieAdjustmentMethodView` without touching
/// it — see `CalorieAdjustmentNewSectionView`. At accessibility sizes the section instead shows the
/// full-width segmented `UISegmentCalorieAdjustmentMethodView` reused verbatim (Decision 10 analog).
///
/// Activity level is a single categorical pick (no value slot), so its neutral closed label is the input
/// name; this is one of two slots in the calorie section (method + value), so — like the body-fat method
/// control — the neutral closed label is "Method" to distinguish it from the value slot.
struct UICalorieAdjustmentMethodMenuButtonView: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Menu {
            ForEach(CalorieAdjustmentMethod.allCases, id: \.self) { method in
                Button {
                    model.calorieAdjustmentMethod = method
                } label: {
                    Text(method.displayName)
                }
            }
        } label: {
            Text("Method")
        }
        .accessibilityIdentifier("calorieAdjustmentMethodMenu")
    }
}

#Preview {
    UICalorieAdjustmentMethodMenuButtonView(model: ProfileViewModel())
}
