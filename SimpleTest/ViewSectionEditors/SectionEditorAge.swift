//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorAge: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        VStack {
            UIWheelPickerAgeView(value: $model.age)
        }
        .accessibilityIdentifier("editorAge")
    }
}

#Preview {
    SectionEditorAge(model: ProfileViewModel())
}
