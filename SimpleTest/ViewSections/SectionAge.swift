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
    @Bindable var sectionManager : SectionManagerViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Age",
            icon: .age,
            isExpanded: $sectionManager.ageIsExpanded,
            validationText: "",
            sectionSummaryValueView: {
                UISectionSummaryValueAge(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorAge(model: model)
            }
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionAge(model: ProfileViewModel(), sectionManager: sectionManager)
}
