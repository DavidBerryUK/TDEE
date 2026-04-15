//
//  SectionCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 09/04/2026.
//

import SwiftUI

struct SectionCalorieAdjustment: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        
        UILayoutSectionView(
            title: "\(model.calorieAdjustmentMethod.sectionTitle)",
            icon: .calorie,
            isExpanded: $model.calorieAdjustmentExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueCalorieAdjustment(model: model)
            },
            editorView: {
                SectionEditorCalorieAdjustment(model: model)
            }
        )
    }
}

#Preview("Cut") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return SectionCalorieAdjustment(model: model)
}

#Preview("Maintain") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    return SectionCalorieAdjustment(model: model)
}

#Preview("Bulk") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return SectionCalorieAdjustment(model: model)
}

