//
//  UISectionSummaryCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 10/04/2026.
//

import SwiftUI

struct UISectionSummaryValueMacroMix: View {

    @Bindable var macroMix: MacroSplitViewModel
    @Bindable var sectionManager : SectionManagerViewModel

    private var displayText: String {
        if let selectedOption = macroMix.selectedOption {
            return selectedOption.name
        } else {
            return "No selection"
        }
    }

    var body: some View {
        HStack {
            Text(displayText)
                .contentTransition(.interpolate)
                .animation(.easeInOut, value: sectionManager.macroMixExpanded)
                .foregroundColor(UITextStyleResolver.fontColor(isExpanded: sectionManager.macroMixExpanded))
                .fontWeight(UITextStyleResolver.fontWeight(isExpanded: sectionManager.macroMixExpanded))
                .accessibilityLabel("Selected macro mix")
                .accessibilityValue(displayText)
        }
    }
}
//#Preview("collapsed") {
//    @Previewable @State var macroMix: MacroSplitOptionModel =    MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()).items.first!
//    @Previewable @State var isExpanded : Bool = false
//     UISectionSummaryValueMacroMix(macroMix: macroMix, isExpanded: isExpanded)
//}
//
//#Preview("expanded") {
//    @Previewable @State var macroMix: MacroSplitOptionModel =    MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()).items.first!
//    @Previewable  @State var isExpanded : Bool = true
//    UISectionSummaryValueMacroMix(macroMix: macroMix, isExpanded: isExpanded)
//}
