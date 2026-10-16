//
//  SectionBodyFatPercentage.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// A view section for managing the user's body fat percentage measurement.
struct SectionBodyFatPercentage: View {

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
    SectionBodyFatPercentage(model: ProfileViewModel(), sectionManager: SectionManagerViewModel(), proxy: nil)
}
