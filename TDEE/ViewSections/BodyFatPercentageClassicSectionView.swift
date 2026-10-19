//
//  BodyFatPercentageClassicSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// The Classic body-fat-percentage input section (story 023) — today's wheel picker.
///
/// The main input's section factory (`MainSectionProfileInput`) picks this or the future
/// `BodyFatPercentageNewSectionView` from `InputStyleManager`; every input currently resolves to Classic.
struct BodyFatPercentageClassicSectionView: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {
        UILayoutSectionView(
            title: "Body Fat Percentage",
            icon: .bodyFat,
            isExpanded: $sectionManager.bodyFatPercentageIsExpanded,
            validationText: "",
            accessibilityId: "sectionBodyFatPercentage",
            sectionId: "sectionBodyFatPercentage",
            sectionSummaryValueView: {
                UISectionSummaryValueBodyFat(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorBodyFatPercentage(model: model)
            },
            proxy: proxy
        )
    }
}

#Preview {
    BodyFatPercentageClassicSectionView(model: ProfileViewModel(), sectionManager: SectionManagerViewModel(), proxy: nil)
}
