//
//  SectionEditorHeight.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: this editor keeps the height control as a unit segment + wheel picker — the
// segment selects the unit of measure (cm / inches / feet & inches), the wheel enters the value. It
// shows the themed wheel (UIWheelHeightThemed) when the active theme supplies picker colours and the
// plain wheel (UIWheelHeightPlain) otherwise; both are .pickerStyle(.wheel), so keep them wheels,
// never menus, and keep the segment. Story-023 Themed/Plain wiring.

import SwiftUI

struct SectionEditorHeight: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.palette) private var palette

    var body: some View {
        VStack {
            UISegmentUomLengthView(option: $model.heightUom)
                .padding(.horizontal, 8)
            // The active theme chooses the wheel's dressing (UIWheelHeightThemed vs UIWheelHeightPlain).
            if palette.isPickerThemed {
                UIWheelHeightThemed(value: $model.height, unitOfMeasure: $model.heightUom)
            } else {
                UIWheelHeightPlain(value: $model.height, unitOfMeasure: $model.heightUom)
            }
        }
    }
}

#Preview {
    SectionEditorHeight(model: ProfileViewModel())
}
