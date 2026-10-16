//
//  SectionEditorHeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains UI components that must remain as segment + wheel picker.
// The segment control selects unit of measure (cm/inches/feet), wheel pickers enter values.
// Changing picker styles alters the user experience.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct SectionEditorHeight: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        VStack {
            UISegmentUomLengthView(option: $model.heightUom)
            UIWheelPickerHeightView(value: $model.height, unitOfMeasure: $model.heightUom)
        }
    }
}

#Preview {
    SectionEditorHeight(model: ProfileViewModel())
}
