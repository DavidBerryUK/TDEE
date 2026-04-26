//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionMacroMix: View {
        
    @Bindable var macroMix: MacroSplitViewModel
    
    var body: some View {
        
        UILayoutSectionView(
            title: "Macro Mix",
            icon: .macroMix,
            isExpanded: $macroMix.isExpanded,
            sectionSummaryValueView: {
                UISectionSummaryValueMacroMix(macroMix: macroMix, isExpanded: macroMix.isExpanded)
            },
            editorView: {
                SectionEditorMacroMix(macroMix: macroMix)
            }
        )
    }
}


#Preview("collapsed") {
    @Previewable @State var macroMix = MacroSplitViewModel()
    macroMix.isExpanded = false
    return SectionMacroMix(macroMix: macroMix)
}

#Preview("expanded") {
    @Previewable @State var macroMix = MacroSplitViewModel()
    macroMix.isExpanded = true
    return SectionMacroMix(macroMix: macroMix)
}
