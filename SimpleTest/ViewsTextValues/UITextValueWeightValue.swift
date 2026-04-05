//
//  UITextValueWeightValue.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UITextValueWeightValue: View {
    
    @Bindable var model: ProfileInputViewModel
    
    private var labelMajorUnit: String {
        switch model.weightUom {
        case .kilograms:
            return "kg"
        case .pounds:
            return "pounds"
        case .stonesAndPounds:
            return "stones"
        }
    }
    
    private var labelMinorUnit: String {
        switch model.weightUom {
        case .stonesAndPounds:
            return "pounds"
        default:
            return ""
        }
    }
    
    var body: some View {

        let isExpanded = model.weightIsExpanded
        
        HStack{
            Text(displayWeight.asMajorValue(weight: model.weight, unit: model.weightUom))
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text(labelMajorUnit)
            Text(displayWeight.asMinorValue(weight: model.weight, unit: model.weightUom))
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text(labelMinorUnit)
            
        }
    }
}

#Preview("Read kg") {
    let model = ProfileInputViewModel()
    model.weightUom = .kilograms
    model.weight = 95
    model.weightIsExpanded = false
    return UITextValueWeightValue(model: model)
}

#Preview("Edit kg") {
    let model = ProfileInputViewModel()
    model.weightUom = .kilograms
    model.weight = 95
    model.weightIsExpanded = true
    return UITextValueWeightValue(model: model)
}

#Preview("Read pounds") {
    let model = ProfileInputViewModel()
    model.weightUom = .pounds
    model.weight = WeightConvertor.toKilograms(pounds: 175)
    model.weightIsExpanded = false
    return UITextValueWeightValue(model: model)
}

#Preview("Edit pounds") {
    let model = ProfileInputViewModel()
    model.weightUom = .pounds
    model.weight = WeightConvertor.toKilograms(pounds: 175)
    model.weightIsExpanded = true
    return UITextValueWeightValue(model: model)
}

#Preview("Read stones & pounds") {
    let model = ProfileInputViewModel()
    model.weightUom = .stonesAndPounds
    model.weightIsExpanded = false
    model.weight = WeightConvertor.toKilograms(stones: 18, pounds: 7)
    return UITextValueWeightValue(model: model)
}

#Preview("Edit stones & pounds") {
    let model = ProfileInputViewModel()
    model.weightUom = .stonesAndPounds
    model.weightIsExpanded = true
    model.weight = WeightConvertor.toKilograms(stones: 18, pounds: 7)
    return UITextValueWeightValue(model: model)
}
