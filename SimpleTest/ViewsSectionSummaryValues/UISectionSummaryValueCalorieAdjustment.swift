//
//  UISectionSummaryCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 10/04/2026.
//

import SwiftUI

struct UISectionSummaryValueCalorieAdjustment: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel

    var body: some View {

        if ( model.calorieAdjustmentMethod == .maintain) {
            EmptyView()
        }

        else {
            let isExpanded = sectionManager.calorieAdjustmentExpanded
            HStack {
                // Nested stack to kill the gap between prefix and number
                HStack(spacing: 0) {
                    Text("\(model.calorieAdjustmentMethod.adjustmentPrefix)")
                        .contentTransition(.interpolate)
                        .animation(.easeInOut, value: model.age)
                        .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded))
                        .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                        .accessibilityLabel("Calorie adjustment method")

                    Text("\(Int(model.calorieAdjustment))")
                        .contentTransition(.numericText())
                        .animation(.easeInOut, value: model.age)
                        .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded))
                        .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                        .accessibilityLabel("Calorie adjustment value")
                }

                Text("kCals")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: model.height)
                    .accessibilityLabel("Calorie units")
            }
        }
    }
}

#Preview("Cut - Closed") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    sectionManager.calorieAdjustmentExpanded = false
    return UISectionSummaryValueCalorieAdjustment(model: model, sectionManager: sectionManager)
}

#Preview("Cut - Open") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    sectionManager.calorieAdjustmentExpanded = true
    return UISectionSummaryValueCalorieAdjustment(model: model, sectionManager: sectionManager)
}

#Preview("Maintain - Closed") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    model.calorieAdjustment = 250
    sectionManager.calorieAdjustmentExpanded = false
    return UISectionSummaryValueCalorieAdjustment(model: model, sectionManager: sectionManager)
}

#Preview("Maintain - Open") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    model.calorieAdjustment = 250
    sectionManager.calorieAdjustmentExpanded = true
    return UISectionSummaryValueCalorieAdjustment(model: model, sectionManager: sectionManager)
}


#Preview("Bulk - Closed") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    sectionManager.calorieAdjustmentExpanded = false
    return UISectionSummaryValueCalorieAdjustment(model: model, sectionManager: sectionManager)
}

#Preview("Bulk - Open") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    sectionManager.calorieAdjustmentExpanded = true
    return UISectionSummaryValueCalorieAdjustment(model: model, sectionManager: sectionManager)
}
