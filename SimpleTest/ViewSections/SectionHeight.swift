//
//  SectionHeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// A view section for displaying and editing the user's height.
struct SectionHeight: View {

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
    SectionHeight(model: ProfileViewModel(), sectionManager: sectionManager, proxy: nil)
}
