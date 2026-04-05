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
            isExpanded: $model.activityLevelIsExpanded,
            valueView: {
                Text("Pending Activty Level")
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
