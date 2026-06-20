//
//  SectionCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 09/04/2026.
//

import SwiftUI

struct SectionCalorieAdjustment: View {
    
    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    
    var body: some View {
        
        UILayoutSectionView(
            title: "\(model.calorieAdjustmentMethod.sectionTitle)",
            icon: .calorie,
            isExpanded: $sectionManager.calorieAdjustmentExpanded,
            validationText: "",
            sectionSummaryValueView: {
                UISectionSummaryValueCalorieAdjustment(model: model, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorCalorieAdjustment(model: model)
            }
        )
    }
}

#Preview("Cut") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return SectionCalorieAdjustment(model: model, sectionManager: sectionManager)
}

#Preview("Maintain") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    return SectionCalorieAdjustment(model: model, sectionManager: sectionManager)
}

#Preview("Bulk") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return SectionCalorieAdjustment(model: model, sectionManager: sectionManager)
}

