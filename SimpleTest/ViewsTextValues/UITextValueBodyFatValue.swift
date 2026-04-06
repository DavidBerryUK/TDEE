//
//  UITextValueBodyFatValue.swift
//  SimpleTest
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

struct UITextValueBodyFatValue: View {
    
    @Bindable var model: ProfileInputViewModel
        
    private var labelValue: String {
        switch model.bodyFatPercentageMethod {
        case .omit:
            return "omitted"
        case .estimate:
            return "estimated"
        case .manualEntry:
            return ""
        }
    }
    
    private var dataValue: String {
        switch model.bodyFatPercentageMethod {
        case .manualEntry:
            return "\(model.bodyFatPercentage)"
        default:
            return ""
        }
    }
    
    private var labelSuffix: String {
        switch model.bodyFatPercentageMethod {
        case .manualEntry:
            return "%"
        default:
            return ""
        }
    }
    
    
    var body: some View {
        
        let isExpanded = model.bodyFatPercentageIsExpanded
        
        HStack{
            Text(labelValue)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.bodyFatPercentageMethod)
            Text(dataValue)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: model.bodyFatPercentage)
                .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            Text(labelSuffix)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.bodyFatPercentageMethod)
        }
    }
}

#Preview("Read Omit") {
    let model = ProfileInputViewModel()
    model.bodyFatPercentageMethod = .omit
    model.bodyFatPercentage = 15.75
    model.bodyFatPercentageIsExpanded = false
    return UITextValueBodyFatValue(model: model)
}

#Preview("Read Only Estimated") {
    let model = ProfileInputViewModel()
    model.bodyFatPercentageMethod = .estimate
    model.bodyFatPercentage = 15.75
    model.bodyFatPercentageIsExpanded = false
    return UITextValueBodyFatValue(model: model)
}

#Preview("Read Only Manual Entry") {
    let model = ProfileInputViewModel()
    model.bodyFatPercentageMethod = .manualEntry
    model.bodyFatPercentage = 15.75
    model.bodyFatPercentageIsExpanded = false
    return UITextValueBodyFatValue(model: model)
}
