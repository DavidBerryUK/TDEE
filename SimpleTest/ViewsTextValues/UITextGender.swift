//
//  UITextAge.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UITextGender: View {
    
    @Binding var model: ProfileInputViewModel
    
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
    @Previewable @State var model = ProfileInputViewModel()
    model.gender = .male
    model.genderIsExpanded = false
    return UITextGender(model: $model)
}

#Preview("Edit Mode") {
    @Previewable @State var model = ProfileInputViewModel()
    model.gender = .female
    model.genderIsExpanded = true
    return UITextGender(model: $model)
}
