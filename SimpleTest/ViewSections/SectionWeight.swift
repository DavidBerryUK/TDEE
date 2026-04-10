//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionWeight: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Weight",
            icon: .weight,
            isExpanded: $model.weightIsExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueWeight(model: model)
            },
            editorView: {
                SectionEditorWeight(model: model)
            }
        )
    }
}

#Preview {
    SectionWeight(model: ProfileInputViewModel())
}
