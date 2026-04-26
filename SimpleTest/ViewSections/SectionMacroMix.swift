//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionMacroMix: View {
        
    @Bindable var macroMix: MacroSplitViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    
    var body: some View {
        
        UILayoutSectionView(
            title: "Macro Mix",
            icon: .macroMix,
            isExpanded: $sectionManager.macroMixExpanded,
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
    return SectionMacroMix(macroMix: macroMix, sectionManager: sectionManager)
}

#Preview("expanded") {
    @Previewable @State var macroMix = MacroSplitViewModel()
    @Previewable @State var sectionManager = SectionManagerViewModel()
    sectionManager.macroMixExpanded = true
    return SectionMacroMix(macroMix: macroMix, sectionManager: sectionManager)
}
