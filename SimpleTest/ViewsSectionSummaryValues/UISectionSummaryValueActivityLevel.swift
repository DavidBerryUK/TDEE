//
//  UITextValueWeightValue.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UISectionSummaryValueActivityLevel: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel

    var body: some View {

        let isExpanded = sectionManager.activityLevelIsExpanded

        HStack{
            Text( model.activityLevel.displayShortName)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.activityLevel)
                .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .accessibilityLabel("Activity level value")
                .accessibilityValue(model.activityLevel.displayShortName)
        }
    }
}

#Preview("Read Athlete") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.activityLevel = .athlete
    sectionManager.activityLevelIsExpanded = false
    return UISectionSummaryValueActivityLevel(model: model, sectionManager: sectionManager)
}

#Preview("Edit Light") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.activityLevel = .lightExercise
    sectionManager.activityLevelIsExpanded = true
    return UISectionSummaryValueActivityLevel(model: model, sectionManager: sectionManager)
}
