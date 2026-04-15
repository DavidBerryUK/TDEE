//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionBodyFatPercentage: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Body Fat Percentage",
            icon: .bodyFat,
            isExpanded: $model.bodyFatPercentageIsExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueBodyFat(model: model)
            },
            editorView: {
                SectionEditorBodyFatPercentage(model: model)
            }
        )
    }
}

#Preview {
    SectionBodyFatPercentage(model: ProfileViewModel())
}
