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
        
        let validationText = model.height.isNaN ||  model.height == 0 ? "Please enter a valid Height" : ""
        
        UILayoutSectionView(
            title: "Height",
            icon: .height,
            isExpanded: $sectionManager.heightIsExpanded,
            validationText: validationText,
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
