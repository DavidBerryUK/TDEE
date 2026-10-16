//
//  SectionEditorBodyFatPercentage.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file uses UILayoutExpandingPanel to conditionally show/hide the picker.
// When "Omit" or "Estimate" is selected, the picker area is hidden.
// When "Manual Entry" is selected, the picker area expands to show the wheel pickers.
// Changing this behavior alters the user experience significantly.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct SectionEditorBodyFatPercentage: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        UILayoutExpandingPanel(
            isOpen: $model.bodyFatPercentageShowManualEntry,
            header: {
                UISegmentBodyFatCalcMethodView(option: $model.bodyFatPercentageMethod)
                    .padding(.horizontal, 8)
                    .accessibilityLabel("Body fat percentage calculation method selector")
            }
        ) {
            UIWheelPickerBodyFatView(value: $model.bodyFatPercentage)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview("omit") {
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .omit
    return SectionEditorBodyFatPercentage(model: model)
}

#Preview("Estimate") {
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .estimate
    return SectionEditorBodyFatPercentage(model: model)
}

#Preview("Manual Entry") {
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .manualEntry
    model.bodyFatPercentage = 15.2
    return SectionEditorBodyFatPercentage(model: model)
}
