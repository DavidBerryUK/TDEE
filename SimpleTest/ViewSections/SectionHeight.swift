//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionHeight: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Height",
            icon: .height,
            isExpanded: $model.heightIsExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueHeight(model: model)
            },
            editorView: {
                SectionEditorHeight(model: model)
            }
        )
    }
}

#Preview {
    SectionHeight(model: ProfileInputViewModel())
}
