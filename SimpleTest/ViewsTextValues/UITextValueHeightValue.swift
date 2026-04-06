//
//  UITextValueWeightValue.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UITextValueHeightValue: View {
    
    @Bindable var model: ProfileInputViewModel
    
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

        let isExpanded = model.heightIsExpanded
        
        HStack{
            Text(displayLength.asMajorValue(length: model.height, unit: model.heightUom))
                .contentTransition(.numericText())
                .animation(.easeInOut, value: model.height)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text(labelMajorUnit)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.height)
            Text(displayLength.asMinorValue(length: model.height, unit: model.heightUom))
                .contentTransition(.numericText())
                .animation(.easeInOut, value: model.height)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text(labelMinorUnit)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.height)
            
        }
    }
}

#Preview("Read cm") {
    let model = ProfileInputViewModel()
    model.heightUom = .centimeters
    model.height = 120
    model.heightIsExpanded = false
    return UITextValueHeightValue(model: model)
}

#Preview("Edit cm") {
    let model = ProfileInputViewModel()
    model.heightUom = .centimeters
    model.height = 120
    model.heightIsExpanded = true
    return UITextValueHeightValue(model: model)
}

#Preview("Read inches") {
    let model = ProfileInputViewModel()
    model.heightUom = .inches
    model.height = LengthConverter.toCentimeters(inches: 200)
    model.heightIsExpanded = false
    return UITextValueHeightValue(model: model)
}

#Preview("Edit inches") {
    let model = ProfileInputViewModel()
    model.heightUom = .inches
    model.height = LengthConverter.toCentimeters(inches: 100)
    model.heightIsExpanded = true
    return UITextValueHeightValue(model: model)
}

#Preview("Read feet & inches") {
    let model = ProfileInputViewModel()
    model.heightUom = .feetAndInches
    model.heightIsExpanded = false
    model.height = LengthConverter.toCentimeters(feet: 5, inches: 7)
    return UITextValueHeightValue(model: model)
}

#Preview("Edit feet & inches") {
    let model = ProfileInputViewModel()
    model.heightUom = .feetAndInches
    model.heightIsExpanded = true
    model.height = LengthConverter.toCentimeters(feet: 5, inches: 10)
    return UITextValueHeightValue(model: model)
}
