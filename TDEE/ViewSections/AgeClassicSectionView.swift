//
//  AgeClassicSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// The Classic age input section (story 023) — today's wheel picker.
///
/// The main input's section factory (`MainSectionProfileInput`) picks this or the future
/// `AgeNewSectionView` from `InputStyleManager`; every input currently resolves to Classic.
struct AgeClassicSectionView: View {

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
    AgeClassicSectionView(model: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository), sectionManager: sectionManager, proxy: nil)
}
