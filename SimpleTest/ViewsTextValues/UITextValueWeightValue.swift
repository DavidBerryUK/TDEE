//
//  UITextValueWeightValue.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UITextValueWeightValue: View {
    
    @Binding var model: ProfileInputViewModel
    
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
    
    private var labelMajorValue: String {
        switch model.weightUom {
        case .kilograms:
            return "\(DisplayFormat.WeightAsKg(kilograms: model.weight))"
        case .pounds:
            return "\(DisplayFormat.WeightAsPounds(kilograms: model.weight))"
        case .stonesAndPounds:
            return "\(DisplayFormat.WeightAsStonesOnly(kilograms: model.weight))"
        }
    }
    
    private var labelMinorValue: String {
        switch model.weightUom {
        case .kilograms:
            return ""
        case .pounds:
            return ""
        case .stonesAndPounds:
            return "\(DisplayFormat.WeightAsPoundsOnly(kilograms: model.weight))"
        }
    }
    
    
    var body: some View {

        let isExpanded = model.weightIsExpanded
        
        HStack{
            Text(labelMajorValue)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text(labelMajorUnit)
            Text(labelMinorValue)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text(labelMinorUnit)
            
        }
    }
}

#Preview("Read kg") {
    @Previewable @State var model = ProfileInputViewModel()
    model.weightUom = .kilograms
    model.weight = 95
    model.weightIsExpanded = false
    return UITextValueWeightValue(model: $model)
}

#Preview("Edit kg") {
    @Previewable @State var model = ProfileInputViewModel()
    model.weightUom = .kilograms
    model.weight = 95
    model.weightIsExpanded = true
    return UITextValueWeightValue(model: $model)
}

#Preview("Read pounds") {
    @Previewable @State var model = ProfileInputViewModel()
    model.weightUom = .pounds
    model.weight = ConversionUtility.toKilograms(pounds: 175)
    model.weightIsExpanded = false
    return UITextValueWeightValue(model: $model)
}

#Preview("Edit pounds") {
    @Previewable @State var model = ProfileInputViewModel()
    model.weightUom = .pounds
    model.weight = ConversionUtility.toKilograms(pounds: 175)
    model.weightIsExpanded = true
    return UITextValueWeightValue(model: $model)
}

#Preview("Read stones & pounds") {
    @Previewable @State var model = ProfileInputViewModel()
    model.weightUom = .stonesAndPounds
    model.weightIsExpanded = false
    model.weight = ConversionUtility.toKilograms(stones: 18, pounds: 7)
    return UITextValueWeightValue(model: $model)
}

#Preview("Edit stones & pounds") {
    @Previewable @State var model = ProfileInputViewModel()
    model.weightUom = .stonesAndPounds
    model.weightIsExpanded = true
    model.weight = ConversionUtility.toKilograms(stones: 18, pounds: 7)
    return UITextValueWeightValue(model: $model)
}
