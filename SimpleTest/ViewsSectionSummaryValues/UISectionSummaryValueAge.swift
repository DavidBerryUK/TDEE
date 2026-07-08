//
//  UITextAge.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UISectionSummaryValueAge: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel

    var body: some View {

        let isExpanded = sectionManager.ageIsExpanded

        HStack{
            Text("\(model.age)")
                .contentTransition(.numericText())
                .animation(.easeInOut, value: model.age)
                .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .accessibilityLabel("Age value")
            Text("years")
                .accessibilityLabel("Age units")
        }
    }
}

#Preview("Read Only") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.age = 34
    sectionManager.ageIsExpanded = false
    return UISectionSummaryValueAge(model: model, sectionManager: sectionManager)
}

#Preview("Being Edited") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.age = 34
    sectionManager.ageIsExpanded = true
    return UISectionSummaryValueAge(model: model, sectionManager: sectionManager)
}
