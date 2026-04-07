//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionActivityLevel: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        UILayoutSectionView(
            title: "Activity Level",
            icon: .activityLevel,
            isExpanded: $model.activityLevelIsExpanded,
            valueView: {
                UITextValueActivityLevel(model: model)
            },
            content: {
                SectionEditorActivityLevel(model: model)
            }
        )
    }
}

#Preview {
    SectionActivityLevel(model: ProfileInputViewModel())
}
