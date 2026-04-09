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
        
        var perDay = Int(model.calorieAdjustment)
        var perWeek = Int(model.calorieAdjustment * 7)
        var adjustmentText = ""
        
        switch(model.calorieAdjustmentMethod ) {
        case .cut:
            adjustmentText = "Reduce"
        case .maintain:
            adjustmentText = "Adjust"
            perDay = 0
            perWeek = 0
        case .bulk:
            adjustmentText = "Increase"
        }
        
        
        return Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
            GridRow {
                Text("\(adjustmentText) Calories per day by")
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                    .gridColumnAlignment(.leading)
                
                Text("\(perDay)")
                    .font(.largeTitle)
                    .gridColumnAlignment(.trailing)
            }
            
            GridRow {
                Text("\(adjustmentText) Calories per Week by")
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                    .gridColumnAlignment(.leading)
                
                Text("\(perWeek)")
                    .font(.largeTitle)
                    .gridColumnAlignment(.trailing)
            }
            
            GridRow {
                Slider(
                    value: $model.calorieAdjustment,
                    in: 0...1000,
                    step: 25
                )
                .gridCellColumns(2)
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
