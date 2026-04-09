//
//  SectionCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 09/04/2026.
//

import SwiftUI

struct SectionCalorieAdjustment: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        VStack {
            UISegmentCalorieAdjustmentMethodView(
                option: Binding(
                    get: { model.calorieAdjustmentMethod },
                    set: { newValue in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            model.calorieAdjustmentMethod = newValue
                        }
                    }
                )
            )
            
            if model.calorieAdjustmentMethod != .maintain {
                SectionEditorCalorieAdjustment(model: model)
                    .padding(.top, 12)
            }
        }
        .padding(16)
    }
}

#Preview("Cut") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return SectionCalorieAdjustment(model: model)
}

#Preview("Maintain") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .maintain
    return SectionCalorieAdjustment(model: model)
}

#Preview("Bulk") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return SectionCalorieAdjustment(model: model)
}

