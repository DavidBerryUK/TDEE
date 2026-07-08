//
//  UITextValueWeightValue.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UISectionSummaryValueHeight: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel

    private var labelMajorUnit: String {
        switch model.heightUom {
        case .centimeters:
            return "cm"
        case .inches:
            return "inches"
        case .feetAndInches:
            return "feet"
        }
    }

    private var labelMinorUnit: String {
        switch model.heightUom {
        case .feetAndInches:
            return "inches"
        default:
            return ""
        }
    }

    var body: some View {

        let isExpanded = sectionManager.heightIsExpanded

        // when height is 0 then there is an error
        let isError = model.height == 0

        HStack{

            //
            // Major Value e.g. 18
            //
            Text(displayLength.asMajorValue(length: model.height, unit: model.heightUom))
                .contentTransition(.numericText())
                .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded, isError: isError))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .animation(.easeInOut, value: model.height)
                .accessibilityLabel("Height major value")

            //
            // Major unit, e.g. Stones
            //
            Text(labelMajorUnit)
                .contentTransition(.interpolate)
                .foregroundColor(UITextStyleResolver.unitOfMeasureColor(isError: isError))
                .animation(.easeInOut, value: model.height)
                .accessibilityLabel("Height major units")

            //
            // Minor Value
            //
            Text(displayLength.asMinorValue(length: model.height, unit: model.heightUom))
                .contentTransition(.numericText())
                .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded, isError: isError))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .animation(.easeInOut, value: model.height)
                .accessibilityLabel("Height minor value")

            //
            // Minor Unit, e.g. Kg, pounds
            //
            Text(labelMinorUnit)
                .contentTransition(.interpolate)
                .foregroundColor(UITextStyleResolver.unitOfMeasureColor(isError: isError))
                .animation(.easeInOut, value: model.height)
                .accessibilityLabel("Height minor units")

        }
    }
}

#Preview("Read cm") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.heightUom = .centimeters
    model.height = 120
    sectionManager.heightIsExpanded = false
    return UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
}

#Preview("Edit cm") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.heightUom = .centimeters
    model.height = 120
    sectionManager.heightIsExpanded = true
    return UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
}

#Preview("Read inches") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.heightUom = .inches
    model.height = LengthConverter.toCentimeters(inches: 200)
    sectionManager.heightIsExpanded = false
    return UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
}

#Preview("Edit inches") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.heightUom = .inches
    model.height = LengthConverter.toCentimeters(inches: 100)
    sectionManager.heightIsExpanded = true
    return UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
}

#Preview("Read feet & inches") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.heightUom = .feetAndInches
    model.height = LengthConverter.toCentimeters(feet: 5, inches: 7)
    sectionManager.heightIsExpanded = false
    return UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
}

#Preview("Edit feet & inches") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.heightUom = .feetAndInches
    model.height = LengthConverter.toCentimeters(feet: 5, inches: 10)
    sectionManager.heightIsExpanded = true
    return UISectionSummaryValueHeight(model: model, sectionManager: sectionManager)
}
