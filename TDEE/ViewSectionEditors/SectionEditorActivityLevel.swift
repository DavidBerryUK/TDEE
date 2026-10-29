//
//  SectionEditorActivityLevel.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: this editor shows the activity-level wheel — a categorical selection best served
// by a wheel, not a dropdown. It shows the themed wheel (UIWheelActivityLevelThemed) when the active
// theme supplies picker colours and the plain wheel (UIWheelActivityLevelPlain) otherwise; both are
// .pickerStyle(.wheel), so keep them wheels, never menus. Story-023 Themed/Plain wiring.

import SwiftUI

struct SectionEditorActivityLevel: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.palette) private var palette

    var body: some View {
        VStack {
            // The active theme chooses the wheel's dressing (UIWheelActivityLevelThemed vs Plain).
            if palette.isPickerThemed {
                UIWheelActivityLevelThemed(value: $model.activityLevel)
            } else {
                UIWheelActivityLevelPlain(value: $model.activityLevel)
            }
        }
    }
}

#Preview {
    SectionEditorActivityLevel(model: ProfileViewModel())
}
