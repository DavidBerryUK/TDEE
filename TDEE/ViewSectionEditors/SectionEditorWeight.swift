//
//  SectionEditorWeight.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains UI components that must remain as segment + wheel picker.
// The segment control selects unit of measure (kg/lb/stones), wheel pickers enter values.
// Changing .pickerStyle(.wheel) to .pickerStyle(.menu) or vice versa alters UX.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct SectionEditorWeight: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        VStack {
            UISegmentUomWeightView(option: $model.weightUom)
            UIWheelPickerWeightView(value: $model.weight, unitOfMeasure: $model.weightUom)
        }
    }
}

#Preview {
    SectionEditorWeight(model: ProfileViewModel())
}
