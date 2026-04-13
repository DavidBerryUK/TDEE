//
//  SectionEditorCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 09/04/2026.
//

import SwiftUI

struct SectionEditorCalorieAdjustment: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        UILayoutExpandingPanel(
            isOpen: $model.calorieAdjustmentShowSliders,
            header: {
                UISegmentCalorieAdjustmentMethodView(option: $model.calorieAdjustmentMethod)
            }
        ) {
            UISliderCalorieAdjustmentValue(model: model)
        }
    }
}


#Preview("Cut") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return SectionEditorCalorieAdjustment(model: model)
}

#Preview("Bulk") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return SectionEditorCalorieAdjustment(model: model)
}

#Preview("Maintain") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .maintain
    return SectionEditorCalorieAdjustment(model: model)
}
