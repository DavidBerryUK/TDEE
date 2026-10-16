//
//  SectionEditorActivityLevel.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains UI components that must remain as wheel pickers.
// Activity level is a categorical selection best served by a wheel picker.
// Changing picker styles alters the user experience.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct SectionEditorActivityLevel: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        VStack {
            UIWheelPickerActivityLevelView(value: $model.activityLevel)
        }
    }
}

#Preview {
    SectionEditorActivityLevel(model: ProfileViewModel())
}
