//
//  UICalorieAdjustmentMethodMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New calorie-adjustment-method control (story 023, input #10) for compact and regular sizes.
///
/// A `Menu` whose label is the current method's full name (`Cut` / `Maintain` / `Bulk`) plus a selector
/// chevron, that rebinds `model.calorieAdjustmentMethod` — the Classic segmented control's 3-case pick,
/// surfaced as a dropdown. The full name and chevron make the control read as a value picker, the
/// discoverability fix for the old neutral "Method" label (Decision 10), mirroring the other New menu
/// buttons (`UIActivityLevelMenuButtonView` / `UIBodyFatMethodMenuButtonView`), and replacing
/// `UISegmentCalorieAdjustmentMethodView` without touching it — see `CalorieAdjustmentNewSectionView`. At
/// accessibility sizes the section instead shows the full-width segmented
/// `UISegmentCalorieAdjustmentMethodView` reused verbatim (Decision 10 analog).
///
/// This is one of two slots in the calorie section (method + value). Unlike activity level — a single
/// categorical pick — the method name here also doubles as a distinguisher: showing the current method
/// (`Cut` / `Maintain` / `Bulk`) keeps it legible next to the value slot, which carries the adjustment
/// number.
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
            // Full name + a selector chevron, so the control reads as a value picker.
            HStack(spacing: 4) {
                Text(model.calorieAdjustmentMethod.displayName)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("calorieAdjustmentMethodMenu")
    }
}

#Preview {
    UICalorieAdjustmentMethodMenuButtonView(model: ProfileViewModel())
}
