//
//  SectionEditorBodyFatPercentage.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: this editor uses UILayoutExpandingPanel to show the body-fat wheel only for
// Manual Entry — when "Omit" or "Estimate" is selected the picker area is hidden; for "Manual Entry"
// it expands to the wheel. It shows the themed wheel (UIWheelBodyFatThemed) when the active theme
// supplies picker colours and the plain wheel (UIWheelBodyFatPlain) otherwise; both are
// .pickerStyle(.wheel). Keep the manual-entry gate and the wheels (never menus). Story-023
// Themed/Plain wiring.

import SwiftUI

struct SectionEditorBodyFatPercentage: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.palette) private var palette

    var body: some View {
        UILayoutExpandingPanel(
            isOpen: $model.bodyFatPercentageShowManualEntry,
            header: {
                UISegmentBodyFatCalcMethodView(option: $model.bodyFatPercentageMethod)
                    .segmentDressing()
                    .padding(.horizontal, 8)
                    .accessibilityLabel("Body fat percentage calculation method selector")
            }
        ) {
            Group {
                // The active theme chooses the wheel's dressing (UIWheelBodyFatThemed vs Plain).
                if palette.isPickerThemed {
                    UIWheelBodyFatThemed(value: $model.bodyFatPercentage)
                } else {
                    UIWheelBodyFatPlain(value: $model.bodyFatPercentage)
                }
            }
            // Match the weight section: a 16pt (Spacing.large) top/bottom padding around the wheel so it
            // breathes below the calculation-method segment instead of sitting tight under it.
            .padding(.vertical, Spacing.large)
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
