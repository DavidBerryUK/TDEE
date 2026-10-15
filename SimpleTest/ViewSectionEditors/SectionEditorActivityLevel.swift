//
//  SectionEditorActivityLevel.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorActivityLevel: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Picker("Activity Level", selection: $model.activityLevel) {
            ForEach(ActivityLevel.allCases, id: \.self) { level in
                Text(level.displayShortName)
            }
        }
        .pickerStyle(.menu)
        .accessibilityLabel("Activity level")
    }
}

#Preview {
    SectionEditorActivityLevel(model: ProfileViewModel())
}
