//
//  SectionEditorCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 09/04/2026.
//

import SwiftUI

struct SectionEditorCalorieAdjustment: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                UILayoutExpandingPanel(
                    isOpen: $model.calorieAdjustmentShowSliders,
                    header: {
                        UISegmentCalorieAdjustmentMethodView(option: $model.calorieAdjustmentMethod)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.bottom, 8)
                    }
                ) {
                    UISliderCalorieAdjustmentValue(model: model)
                        .id("calorieSliderAnchor") // Add an anchor to this view
                        .padding(16)
                }
            }
            .onChange(of: model.calorieAdjustmentShowSliders) { valueA, valueB in
                if valueB {
                    Task {
                        try? await Task.sleep(nanoseconds: 200_000_000) // Delay of 0.2 seconds (200 ms)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("calorieSliderAnchor", anchor: .bottom) // Scroll to the anchor
                        }
                    }
                }
            }                        
        }
    }
}

#Preview("Cut") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return SectionEditorCalorieAdjustment(model: model)
}

#Preview("Bulk") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return SectionEditorCalorieAdjustment(model: model)
}

#Preview("Maintain") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    return SectionEditorCalorieAdjustment(model: model)
}
