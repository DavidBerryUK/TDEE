//
//  SectionEditorCalorieAdjustment.swift
//  TDEE
//
//  Created by David Berry on 09/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file uses UILayoutExpandingPanel to conditionally show/hide the slider.
// When "Maintain" is selected, the slider area is hidden (no adjustment needed).
// When "Cut" or "Bulk" is selected, the slider area expands to show adjustment.
// Changing this behavior alters the user experience significantly.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct SectionEditorCalorieAdjustment: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            UILayoutExpandingPanel(
                isOpen: $model.calorieAdjustmentShowSliders,
                header: {
                    UISegmentCalorieAdjustmentMethodView(option: $model.calorieAdjustmentMethod)
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        .padding(.bottom, 8)
                }
            ) {
                UISliderCalorieAdjustmentValue(model: model)
                    .id("calorieSliderAnchor") // Add an anchor to this view
                    .padding(16)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview("Cut") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return SectionEditorCalorieAdjustment(model: model)
}

#Preview("Bulk") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return SectionEditorCalorieAdjustment(model: model)
}

#Preview("Maintain") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    return SectionEditorCalorieAdjustment(model: model)
}
