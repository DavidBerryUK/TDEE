//
//  UITextAge.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UISectionSummaryValueGender: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager : SectionManagerViewModel

    var body: some View {

        let isExpanded = sectionManager.genderIsExpanded

        HStack{
            Text(model.gender.displayName)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.gender)
                .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .accessibilityLabel("Gender value")
        }
    }
}

#Preview("Read Mode") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.gender = .male
    sectionManager.genderIsExpanded = false
    return UISectionSummaryValueGender(model: model, sectionManager: sectionManager)
}

#Preview("Edit Mode") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.gender = .female
    sectionManager.genderIsExpanded = true
    return UISectionSummaryValueGender(model: model, sectionManager: sectionManager)
}
