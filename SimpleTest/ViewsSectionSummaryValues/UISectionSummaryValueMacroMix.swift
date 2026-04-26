//
//  UISectionSummaryCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 10/04/2026.
//

import SwiftUI

struct UISectionSummaryValueMacroMix: View {
    
    @Bindable var macroMix: MacroSplitViewModel
    var isExpanded : Bool
    
    var body: some View {                        
        HStack {
            Text("\(macroMix.isExpanded)")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: macroMix.isExpanded)
                    .foregroundColor(UITextStyleResolver.color(isExpanded: isExpanded))
                    .fontWeight(UITextStyleResolver.weight(isExpanded: isExpanded))
            
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
