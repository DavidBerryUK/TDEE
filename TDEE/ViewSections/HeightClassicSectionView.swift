//
//  HeightClassicSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// The Classic height input section (story 023) — today's UOM toggle + wheel picker.
///
/// The main input's section factory (`MainSectionProfileInput`) picks this or the future
/// `HeightNewSectionView` from `InputStyleManager`; every input currently resolves to Classic.
struct HeightClassicSectionView: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {

        let validationText = model.height.isNaN ||  model.height == 0 ? "Please enter a valid Height" : ""

        UILayoutSectionView(
            title: "Height",
            icon: .height,
            isExpanded: $sectionManager.heightIsExpanded,
            validationText: validationText,
            accessibilityId: "sectionHeight",
            sectionId: "sectionHeight",
            sectionSummaryValueView: {
                UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorHeight(model: model)
            },
            proxy: proxy
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    HeightClassicSectionView(model: ProfileViewModel(), sectionManager: sectionManager, proxy: nil)
}
