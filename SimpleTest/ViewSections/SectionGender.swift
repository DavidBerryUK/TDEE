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
    let proxy: ScrollViewProxy?

    var body: some View {
        UILayoutSectionView(
            title: "Gender",
            icon: .gender,
            isExpanded: $sectionManager.genderIsExpanded,
            validationText: "",
            accessibilityId: "sectionGender",
            sectionId: "sectionGender",
            sectionSummaryValueView: {
                UISectionSummaryValueGender(model: model, sectionManager: sectionManager)
            },
            editorView: {
                UISegmentGenderView(option: $model.gender)
            },
            proxy: proxy
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionGender(model: ProfileViewModel(), sectionManager: sectionManager, proxy: nil)
}
