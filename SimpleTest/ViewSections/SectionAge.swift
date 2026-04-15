import SwiftUI
import Observation

//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

struct SectionAge: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Age",
            icon: .age,
            isExpanded: $model.ageIsExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueAge(model: model)
            },
            editorView: {
                SectionEditorAge(model: model)
            }
        )
    }
}

#Preview {
    SectionAge(model: ProfileViewModel())
}
