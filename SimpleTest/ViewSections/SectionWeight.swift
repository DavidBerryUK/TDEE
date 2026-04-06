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
            isExpanded: $model.weightIsExpanded,
            valueView: {
                UITextValueWeightValue(model: model)
            },
            content: {
                SectionEditorWeight(model: model)
            }
        )
    }
}

#Preview {
    SectionWeight(model: ProfileInputViewModel())
}
