//
//  SectionEditorHeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorHeight: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Picker("Height", selection: $model.heightUom) {
            ForEach(OptionLength.allCases, id: \.self) { option in
                Text(option.displayName)
            }
        }
        .pickerStyle(.menu)
        .accessibilityLabel("Height unit")
    }
}

#Preview {
    SectionEditorHeight(model: ProfileViewModel())
}
