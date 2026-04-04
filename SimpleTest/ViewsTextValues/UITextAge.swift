//
//  UITextAge.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UITextAge: View {
    
    @Binding var model: ProfileInputViewModel
    
    let label = "age"
    
    var body: some View {
        
        let isExpanded = model.ageIsExpanded
        
        HStack{
            Text(label)
            Text("\(model.age)")
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text("years")
        }
    }
}

#Preview("Read Only") {
    @Previewable @State var model = ProfileInputViewModel()
    model.age = 34
    model.ageIsExpanded = false
    return UITextAge(model: $model)
}

#Preview("Being Edited") {
    @Previewable @State var model = ProfileInputViewModel()
    model.age = 34
    model.ageIsExpanded = true
    return UITextAge(model: $model)
}
