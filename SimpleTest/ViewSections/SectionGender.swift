//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionGender: View {
    
    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Gender",
            icon: .gender,
            isExpanded: $sectionManager.genderIsExpanded,
            validationText: "",
            sectionSummaryValueView: {
                UISectionSummaryValueGender(model: model, sectionManager: sectionManager)
            },
            editorView: {
                UISegmentGenderView(option: $model.gender)
            }
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionGender(model: ProfileViewModel(), sectionManager: sectionManager)
}
