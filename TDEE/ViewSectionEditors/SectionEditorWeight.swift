//
//  SectionEditorWeight.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: this editor keeps the weight control as a unit segment + wheel picker — the
// segment selects the unit of measure (kg / lb / stones), the wheel enters the value. It shows the
// themed wheel (UIWheelWeightThemed) when the active theme supplies picker colours and the plain
// wheel (UIWheelWeightPlain) otherwise; both are .pickerStyle(.wheel), so keep them wheels, never
// menus, and keep the segment. Story-023 Themed/Plain wiring.

import SwiftUI

struct SectionEditorWeight: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.palette) private var palette

    var body: some View {
        VStack {
            UISegmentUomWeightView(option: $model.weightUom)
                .segmentDressing()
                .padding(.horizontal, 8)
            Group {
                // The active theme chooses the wheel's dressing (UIWheelWeightThemed vs UIWheelWeightPlain).
                if palette.isPickerThemed {
                    UIWheelWeightThemed(value: $model.weight, unitOfMeasure: $model.weightUom)
                } else {
                    UIWheelWeightPlain(value: $model.weight, unitOfMeasure: $model.weightUom)
                }
            }
            // The wheel's container breathes like the height/age section's picker row: a 16pt
            // (Spacing.large) top/bottom padding around it. Without it the wheel sits tight under the
            // unit segment, unlike the age/height sections which pad their container.
            .padding(.vertical, Spacing.large)
        }
    }
}

#Preview {
    SectionEditorWeight(model: ProfileViewModel())
}
