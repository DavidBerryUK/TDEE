//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionMacroSplit: View {
        
    @Bindable var macroMix: MacroSplitViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    
    var body: some View {
        
        UILayoutSectionView(
            title: "Macro Split",
            icon: .macroSplit,
            isExpanded: $sectionManager.macroMixExpanded,
            validationText: "",
            sectionSummaryValueView: {
                UISectionSummaryValueMacroMix(macroMix: macroMix, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorMacroMix(macroMix: macroMix)
            }
        )
    }
}


#Preview("collapsed") {
    @Previewable @State var macroMix = MacroSplitViewModel()
    @Previewable @State var sectionManager = SectionManagerViewModel()
    sectionManager.macroMixExpanded = false
    return SectionMacroSplit(macroMix: macroMix, sectionManager: sectionManager)
}

#Preview("expanded") {
    @Previewable @State var macroMix = MacroSplitViewModel()
    @Previewable @State var sectionManager = SectionManagerViewModel()
    sectionManager.macroMixExpanded = true
    return SectionMacroSplit(macroMix: macroMix, sectionManager: sectionManager)
}
