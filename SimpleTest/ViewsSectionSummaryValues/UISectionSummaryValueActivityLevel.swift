//
//  UITextValueWeightValue.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UISectionSummaryValueActivityLevel: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {

        let isExpanded = model.activityLevelIsExpanded
        
        HStack{
            Text( model.activityLevel.displayShortName)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.activityLevel)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
        }
    }
}

#Preview("Read Athlete") {
    let model = ProfileInputViewModel()
    model.activityLevel = .athlete
    model.activityLevelIsExpanded = false
    return UISectionSummaryValueActivityLevel(model: model)
}

#Preview("Edit Light") {
    let model = ProfileInputViewModel()
    model.activityLevel = .lightExercise
    model.activityLevelIsExpanded = true
    return UISectionSummaryValueActivityLevel(model: model)
}
