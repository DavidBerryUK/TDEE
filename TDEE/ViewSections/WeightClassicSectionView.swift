//
//  WeightClassicSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// The Classic weight input section (story 023) — today's UOM toggle + wheel picker.
///
/// The main input's section factory (`MainSectionProfileInput`) picks this or the future
/// `WeightNewSectionView` from `InputStyleManager`; every input currently resolves to Classic.
struct WeightClassicSectionView: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {

        let validationText = model.weight.isNaN || model.weight == 0 ? "Please enter a valid Weight" : ""

        UILayoutSectionView(
            title: "Weight",
            icon: .weight,
            isExpanded: $sectionManager.weightIsExpanded,
            validationText: validationText,
            accessibilityId: "sectionWeight",
            sectionId: "sectionWeight",
            sectionSummaryValueView: {
                UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorWeight(model: model)
            },
            proxy: proxy
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    WeightClassicSectionView(model: ProfileViewModel(), sectionManager: SectionManagerViewModel(), proxy: nil)
}
