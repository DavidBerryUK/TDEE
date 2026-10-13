//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// A view section for displaying and editing the user's age.
struct SectionAge: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {
        UILayoutSectionView(
            title: "Age",
            icon: .age,
            isExpanded: $sectionManager.ageIsExpanded,
            validationText: "",
            accessibilityId: "sectionAge",
            sectionId: "sectionAge",
            sectionSummaryValueView: {
                UISectionSummaryValueAge(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorAge(model: model)
            },
            proxy: proxy
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionAge(model: ProfileViewModel(), sectionManager: sectionManager, proxy: nil)
}
