//
//  SectionEditorAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains UI components that must remain as wheel pickers.
// Changing picker styles from .wheel to .menu (or vice versa) alters the
// user experience and must be explicitly approved by the user.
// If you need to make changes, report back to the user first.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct SectionEditorAge: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        VStack {
            UIWheelPickerAgeView(value: $model.age)
        }
    }
}

#Preview {
    SectionEditorAge(model: ProfileViewModel())
}
