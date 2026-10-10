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
    let calculationResult: CalculatorResultViewModel

    var body: some View {

        UILayoutSectionView(
            title: "Macro Split",
            icon: .macroSplit,
            isExpanded: $sectionManager.macroMixExpanded,
            validationText: "",
            accessibilityId: "sectionMacroSplit",
            sectionSummaryValueView: {
                UISectionSummaryValueMacroMix(macroMix: macroMix, sectionManager: sectionManager)
            },
            editorView: {
                VStack(spacing: 0) {
                    SectionEditorMacroMix(macroMix: macroMix)
                    SectionMacroMixResults(calculationResults: calculationResult)
                        .padding(.top, Spacing.medium)
                        .padding(.bottom, Spacing.small)
                }
            }
        )
    }
}

// Preview disabled due to compiler crash with @Previewable and @Bindable
// #Preview("collapsed") {
//     @Previewable @State var macroMix = MacroSplitViewModel()
//     @Previewable @State var sectionManager = SectionManagerViewModel()
//     sectionManager.macroMixExpanded = false
//     return SectionMacroSplit(macroMix: macroMix, sectionManager: sectionManager)
// }
//
// #Preview("expanded") {
//     @Previewable @State var macroMix = MacroSplitViewModel()
//     @Previewable @State var sectionManager = SectionManagerViewModel()
//     sectionManager.macroMixExpanded = true
//     return SectionMacroSplit(macroMix: macroMix, sectionManager: sectionManager)
// }
