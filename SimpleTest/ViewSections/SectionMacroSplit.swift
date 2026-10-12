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
    @Binding var path: [EnumAppRoute]

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
                    Text("Current Selection")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)

                    SectionEditorMacroMix(macroMix: macroMix)
                    SectionMacroMixResults(calculationResults: calculationResult)
                        .padding(.top, Spacing.medium)
                        .padding(.bottom, Spacing.small)

                    // Navigation button to manage presets
                    Button("Customise") {
                        path.append(.maintainMacroConfig)
                    }
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal)
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
