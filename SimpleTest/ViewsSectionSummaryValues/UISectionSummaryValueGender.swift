//
//  UITextAge.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UISectionSummaryValueGender: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        
        let isExpanded = model.genderIsExpanded
        
        HStack{
            Text(model.gender.displayName)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.gender)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
        }
    }
}

#Preview("Read Mode") {
    let model = ProfileInputViewModel()
    model.gender = .male
    model.genderIsExpanded = false
    return UISectionSummaryValueGender(model: model)
}

#Preview("Edit Mode") {
    let model = ProfileInputViewModel()
    model.gender = .female
    model.genderIsExpanded = true
    return UISectionSummaryValueGender(model: model)
}
