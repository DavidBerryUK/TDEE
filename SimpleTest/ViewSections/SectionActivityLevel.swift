//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionActivityLevel: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Activity Level",
            icon: .activityLevel,
            isExpanded: $model.activityLevelIsExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueActivityLevel(model: model)
            },
            editorView: {
                SectionEditorActivityLevel(model: model)
            }
        )
    }
}

#Preview {
    SectionActivityLevel(model: ProfileViewModel())
}
