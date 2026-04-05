//
//  UITextAge.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UITextValueGenderView: View {
    
    @Bindable var model: ProfileInputViewModel
    
    let label = "gender"
    
    
    var body: some View {
        
        let isExpanded = model.genderIsExpanded
        
        HStack{
            Text(label)
            Text(model.gender.displayName)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
        }
    }
}

#Preview("Read Mode") {
    let model = ProfileInputViewModel()
    model.gender = .male
    model.genderIsExpanded = false
    return UITextValueGenderView(model: model)
}

#Preview("Edit Mode") {
    let model = ProfileInputViewModel()
    model.gender = .female
    model.genderIsExpanded = true
    return UITextValueGenderView(model: model)
}
