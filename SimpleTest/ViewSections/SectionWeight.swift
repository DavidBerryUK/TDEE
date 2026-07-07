//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionWeight: View {
    
    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    
    var body: some View {
        
        let validationText = model.weight.isNaN || model.weight == 0 ? "Please enter a valid Weight" : ""
        
        UILayoutSectionView(
            title: "Weight",
            icon: .weight,
            isExpanded: $sectionManager.weightIsExpanded,
            validationText: validationText,
            sectionSummaryValueView: {
                UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorWeight(model: model)
            }
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    SectionWeight(model: ProfileViewModel(), sectionManager: sectionManager)
}
