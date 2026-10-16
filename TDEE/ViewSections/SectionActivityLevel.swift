//
//  SectionActivityLevel.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// A view section for selecting the user's activity level.
struct SectionActivityLevel: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {
        UILayoutSectionView(
            title: "Activity Level",
            icon: .activityLevel,
            isExpanded: $sectionManager.activityLevelIsExpanded,
            validationText: "",
            accessibilityId: "sectionActivityLevel",
            sectionId: "sectionActivityLevel",
            sectionSummaryValueView: {
                UISectionSummaryValueActivityLevel(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorActivityLevel(model: model)
            },
            proxy: proxy
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionActivityLevel(model: ProfileViewModel(), sectionManager: sectionManager, proxy: nil)
}
