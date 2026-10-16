//
//  UITextValueBodyFatValue.swift
//  TDEE
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

struct UISectionSummaryValueBodyFat: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel

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

        let isExpanded = sectionManager.bodyFatPercentageIsExpanded

        HStack{
            Text(labelValue)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.bodyFatPercentageMethod)
                .accessibilityLabel("Body fat percentage method")
            Text(dataValue)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: model.bodyFatPercentage)
                .foregroundColor(UITextStyleResolver.fontColor(isExpanded: isExpanded))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .accessibilityLabel("Body fat percentage value")
            Text(labelSuffix)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: model.bodyFatPercentageMethod)
                .accessibilityLabel("Body fat percentage units")
        }
    }
}

#Preview("Read Omit") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .omit
    model.bodyFatPercentage = 15.75
    sectionManager.bodyFatPercentageIsExpanded = false
    return UISectionSummaryValueBodyFat(model: model,sectionManager: sectionManager)
}

#Preview("Read Only Estimated") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .estimate
    model.bodyFatPercentage = 15.75
    sectionManager.bodyFatPercentageIsExpanded = false
    return UISectionSummaryValueBodyFat(model: model,sectionManager: sectionManager)
}

#Preview("Read Only Manual Entry") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .manualEntry
    model.bodyFatPercentage = 15.75
    sectionManager.bodyFatPercentageIsExpanded = false
    return UISectionSummaryValueBodyFat(model: model,sectionManager: sectionManager)
}
