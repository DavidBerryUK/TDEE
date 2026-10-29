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
                .padding(.horizontal, 8)
            // The active theme chooses the wheel's dressing (UIWheelWeightThemed vs UIWheelWeightPlain).
            if palette.isPickerThemed {
                UIWheelWeightThemed(value: $model.weight, unitOfMeasure: $model.weightUom)
            } else {
                UIWheelWeightPlain(value: $model.weight, unitOfMeasure: $model.weightUom)
            }
        }
    }
}

#Preview {
    SectionEditorWeight(model: ProfileViewModel())
}
