import SwiftUI
import Observation

//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

struct SectionAge: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Age",
            isExpanded: $model.ageIsExpanded,
            valueView: {
                UITextAgeValueView(model: model)
            },
            content: {
                SectionEditorAge(model: model)
            }
        )
    }
}

#Preview {
    SectionAge(model: ProfileInputViewModel())
}
