//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionHeight: View {
    
    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Height",
            icon: .height,
            isExpanded: $sectionManager.heightIsExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorHeight(model: model)
            }
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionHeight(model: ProfileViewModel(), sectionManager: sectionManager)
}
