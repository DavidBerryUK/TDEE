//
//  SectionGender.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// A view section for displaying and editing the user's gender.
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
    SectionGender(model: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository), sectionManager: sectionManager, proxy: nil)
}
