//
//  SectionEditorCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 09/04/2026.
//

import SwiftUI


    
struct SectionEditorCalorieAdjustment: View {
    
    @Bindable var model: ProfileInputViewModel
    @State private var isVisible = false
    
    init(model: ProfileInputViewModel) {
        self.model = model
        _isVisible = State(initialValue: model.calorieAdjustmentShowSliders)
    }

    
    var body: some View {
        
        VStack {
            UISegmentCalorieAdjustmentMethodView(option: $model.calorieAdjustmentMethod)
            
            VStack {
                if model.calorieAdjustmentShowSliders || isVisible {
                    UISliderCalorieAdjustmentValue(model: model)
                        .opacity(isVisible ? 1 : 0)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.85),
                       value: model.calorieAdjustmentShowSliders)
        }
        .onChange(of: model.calorieAdjustmentShowSliders) { _, newValue in
            
            if newValue {
                // EXPAND FIRST
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    isVisible = true
                }
            } else {
                // FADE OUT FIRST
                withAnimation(.easeInOut(duration: 0.1)) {
                    isVisible = false
                }
            }
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
