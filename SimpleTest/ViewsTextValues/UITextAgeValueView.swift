//
//  UITextAge.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UITextAgeValueView: View {
    
    @Bindable var model: ProfileInputViewModel
        
    var body: some View {
        
        let isExpanded = model.ageIsExpanded
        
        HStack{
            Text("\(model.age)")
                .contentTransition(.numericText())
                .animation(.easeInOut, value: model.age)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text("years")
        }
    }
}

#Preview("Read Only") {
    let model = ProfileInputViewModel()
    model.age = 34
    model.ageIsExpanded = false
    return UITextAgeValueView(model: model)
}

#Preview("Being Edited") {
    let model = ProfileInputViewModel()
    model.age = 34
    model.ageIsExpanded = true
    return UITextAgeValueView(model: model)
}
