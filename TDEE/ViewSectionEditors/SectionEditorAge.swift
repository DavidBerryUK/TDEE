//
//  SectionEditorAge.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: this editor shows the age wheel — a wheel is best for ordered numeric values, not
// a dropdown. It shows the themed wheel (UIWheelAgeThemed) when the active theme supplies picker
// colours and the plain wheel (UIWheelAgePlain) otherwise; both are .pickerStyle(.wheel), so keep
// them wheels, never menus. The two also differ in where "age in years" sits: the plain (standard)
// wheel puts the caption *inside* the picker (over the wheel, like the height section) and the themed
// (orange) wheel pushes it *outside*, to the section's edge. Story-023 Themed/Plain wiring.

import SwiftUI

struct SectionEditorAge: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.palette) private var palette

    var body: some View {
        VStack {
            // The active theme chooses the wheel's dressing (UIWheelAgeThemed vs UIWheelAgePlain).
            if palette.isPickerThemed {
                UIWheelAgeThemed(value: $model.age)
            } else {
                UIWheelAgePlain(value: $model.age)
            }
        }
    }
}

#Preview {
    SectionEditorAge(model: ProfileViewModel())
}
