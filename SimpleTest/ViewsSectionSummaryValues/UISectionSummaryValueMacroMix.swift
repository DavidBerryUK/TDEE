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
    
    
    var body: some View {                        
        HStack {
            Text("\(sectionManager.macroMixExpanded)")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: sectionManager.macroMixExpanded)
                    .foregroundColor(UITextStyleResolver.color(isExpanded: sectionManager.macroMixExpanded))
                    .fontWeight(UITextStyleResolver.weight(isExpanded: sectionManager.macroMixExpanded))
            
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
