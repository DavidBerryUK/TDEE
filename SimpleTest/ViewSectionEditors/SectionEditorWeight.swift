//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorWeight: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Picker("Weight", selection: $model.weightUom) {
            ForEach(OptionWeight.allCases, id: \.self) { option in
                Text(option.displayName)
            }
        }
        .pickerStyle(.menu)
        .accessibilityLabel("Weight unit")
    }
}

#Preview {
    SectionEditorWeight(model: ProfileViewModel())
}
