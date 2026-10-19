//
//  ActivityLevelClassicSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// The Classic activity-level input section (story 023) — today's wheel picker.
///
/// The main input's section factory (`MainSectionProfileInput`) picks this or the future
/// `ActivityLevelNewSectionView` from `InputStyleManager`; every input currently resolves to Classic.
struct ActivityLevelClassicSectionView: View {

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
    ActivityLevelClassicSectionView(model: ProfileViewModel(), sectionManager: sectionManager, proxy: nil)
}
