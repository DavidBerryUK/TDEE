//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionGender: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Gender",
            isExpanded: $model.genderIsExpanded,
            valueView: {
                UITextValueGenderView(model: model)
            },
            content: {
                UISegmentGenderView(option: $model.gender)
            }
        )
    }
}

#Preview {
    SectionGender(model: ProfileInputViewModel())
}
