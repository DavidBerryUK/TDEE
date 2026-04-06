//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionBodyFatPercentage: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Body Fat Percentage",
            isExpanded: $model.bodyFatPercentageIsExpanded,
            valueView: {
                UITextValueBodyFatValue(model: model)
            },
            content: {
                SectionEditorBodyFatPercentage(model: model)
            }
        )
    }
}

#Preview {
    SectionBodyFatPercentage(model: ProfileInputViewModel())
}
