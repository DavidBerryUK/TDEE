//
//  UISectionSummaryCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 10/04/2026.
//

import SwiftUI

struct UISectionSummaryValueCalorieAdjustment: View {
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        
        if ( model.calorieAdjustmentMethod == .maintain) {
            EmptyView()
        }
        
        else {
            let isExpanded = model.calorieAdjustmentExpanded
            HStack {
                // Nested stack to kill the gap between prefix and number
                HStack(spacing: 0) {
                    Text("\(model.calorieAdjustmentMethod.adjustmentPrefix)")
                        .contentTransition(.interpolate)
                        .animation(.easeInOut, value: model.age)
                        .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                        .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
                    
                    Text("\(Int(model.calorieAdjustment))")
                        .contentTransition(.numericText())
                        .animation(.easeInOut, value: model.age)
                        .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                        .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
                }
                
                Text("kCals")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: model.height)
            }
        }
    }
}

#Preview("Cut - Closed") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    model.calorieAdjustmentExpanded = false
    return UISectionSummaryValueCalorieAdjustment(model: model)
}

#Preview("Cut - Open") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    model.calorieAdjustmentExpanded = true
    return UISectionSummaryValueCalorieAdjustment(model: model)
}

#Preview("Maintain - Closed") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    model.calorieAdjustment = 250
    model.calorieAdjustmentExpanded = false
    model.calorieAdjustmentExpanded = true
    return UISectionSummaryValueCalorieAdjustment(model: model)
}

#Preview("Maintain - Open") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    model.calorieAdjustment = 250
    model.calorieAdjustmentExpanded = true
    return UISectionSummaryValueCalorieAdjustment(model: model)
}


#Preview("Bulk - Closed") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    model.calorieAdjustmentExpanded = false
    return UISectionSummaryValueCalorieAdjustment(model: model)
}

#Preview("Bulk - Open") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    model.calorieAdjustmentExpanded = true
    return UISectionSummaryValueCalorieAdjustment(model: model)
}
