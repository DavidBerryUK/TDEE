//
//  SectionEditorAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorAge: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Picker("Age", selection: $model.age) {
            ForEach(18...100, id: \.self) { year in
                Text("\(year)")
            }
        }
        .pickerStyle(.menu)
        .accessibilityLabel("Age")
    }
}

#Preview {
    SectionEditorAge(model: ProfileViewModel())
}
