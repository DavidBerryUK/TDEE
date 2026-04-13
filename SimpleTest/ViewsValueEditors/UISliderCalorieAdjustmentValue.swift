//
//  UISliderCalorieAdjustmentValue.swift
//  SimpleTest
//
//  Created by David Berry on 11/04/2026.
//

import SwiftUI

struct UISliderCalorieAdjustmentValue: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        
        var perDay = Int(model.calorieAdjustment)
        var perWeek = Int(model.calorieAdjustment * 7)
        var adjustmentTextPerDay = ""
        var adjustmentTextPerWeek = ""
        
        switch(model.calorieAdjustmentMethod ) {
        case .cut:
            adjustmentTextPerDay = "Reduce Calories per day by"
            adjustmentTextPerWeek = "Reduce Calories per week by"
        case .maintain:
            adjustmentTextPerDay = "Maintain"
            adjustmentTextPerWeek = "Maintain"
            perDay = 0
            perWeek = 0
        case .bulk:
            adjustmentTextPerDay = "Increase Calories per day by"
            adjustmentTextPerWeek = "Increase Calories per week by"
        }
        
        return Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
            GridRow {
                Text(adjustmentTextPerDay)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: adjustmentTextPerDay)
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
                Text(adjustmentTextPerWeek)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: adjustmentTextPerWeek)
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
    return UISliderCalorieAdjustmentValue(model: model)
}

#Preview("Bulk") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return UISliderCalorieAdjustmentValue(model: model)
}

#Preview("Maintain") {
    let model = ProfileInputViewModel()
    model.calorieAdjustmentMethod = .maintain
    return UISliderCalorieAdjustmentValue(model: model)
}
