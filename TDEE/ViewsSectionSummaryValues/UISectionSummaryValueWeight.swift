//
//  UITextValueWeightValue.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UISectionSummaryValueWeight: View {
    @Environment(\.palette) private var palette
    
    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    
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

        let isExpanded = sectionManager.weightIsExpanded
        
        // when weight is 0 then there is an error
        let isError = model.weight == 0
        
        
        HStack{
            //
            // Major Value e.g. 95
            //
            Text(DisplayWeight.asMajorValue(weight: model.weight, unit: model.weightUom))
                .contentTransition(.numericText())
                .foregroundColor(UITextStyleResolver.fontColor(palette, isExpanded: isExpanded, isError: isError))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .animation(.easeInOut, value: model.weight)
                .accessibilityLabel("Weight major value")
                .accessibilityValue(DisplayWeight.asMajorValue(weight: model.weight, unit: model.weightUom))

            //
            // Major unit, e.g. kg, pounds, stones
            //
            Text(labelMajorUnit)
                .contentTransition(.interpolate)
                .foregroundColor(UITextStyleResolver.unitOfMeasureColor(palette, isError: isError))
                .animation(.easeInOut, value: model.weight)
                .accessibilityLabel("Weight major units")
                .accessibilityValue(labelMajorUnit)

            //
            // Minor Value
            //
            Text(DisplayWeight.asMinorValue(weight: model.weight, unit: model.weightUom))
                .contentTransition(.numericText())
                .foregroundColor(UITextStyleResolver.fontColor(palette, isExpanded: isExpanded, isError: isError))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: isExpanded))
                .animation(.easeInOut, value: model.weight)
                .accessibilityLabel("Weight minor value")
                .accessibilityValue(DisplayWeight.asMinorValue(weight: model.weight, unit: model.weightUom))

            //
            // Minor Unit, e.g. pounds (when stones)
            //
            Text(labelMinorUnit)
                .contentTransition(.interpolate)
                .foregroundColor(UITextStyleResolver.unitOfMeasureColor(palette, isError: isError))
                .animation(.easeInOut, value: model.weight)
                .accessibilityLabel("Weight minor units")
                .accessibilityValue(labelMinorUnit)

        }
    }
}

#Preview("Read kg") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.weightUom = .kilograms
    model.weight = 95
    sectionManager.weightIsExpanded = false
    return UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
}

#Preview("Edit kg") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.weightUom = .kilograms
    model.weight = 95
    sectionManager.weightIsExpanded = true
    return UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
}

#Preview("Read pounds") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.weightUom = .pounds
    model.weight = WeightConvertor.toKilograms(pounds: 175)
    sectionManager.weightIsExpanded = false
    return UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
}

#Preview("Edit pounds") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.weightUom = .pounds
    model.weight = WeightConvertor.toKilograms(pounds: 175)
    sectionManager.weightIsExpanded = true
    return UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
}

#Preview("Read stones & pounds") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.weightUom = .stonesAndPounds
    sectionManager.weightIsExpanded = false
    model.weight = WeightConvertor.toKilograms(stones: 18, pounds: 7)
    return UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
}

#Preview("Edit stones & pounds") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.weightUom = .stonesAndPounds
    sectionManager.weightIsExpanded = true
    model.weight = WeightConvertor.toKilograms(stones: 18, pounds: 7)
    return UISectionSummaryValueWeight(model: model, sectionManager: sectionManager)
}
