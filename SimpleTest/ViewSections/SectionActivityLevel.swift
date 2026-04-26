//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionActivityLevel: View {
    
    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Activity Level",
            icon: .activityLevel,
            isExpanded: $sectionManager.activityLevelIsExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueActivityLevel(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorActivityLevel(model: model)
            }
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionActivityLevel(model: ProfileViewModel(), sectionManager: sectionManager)
}
