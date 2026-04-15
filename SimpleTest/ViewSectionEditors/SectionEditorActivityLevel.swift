//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

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
