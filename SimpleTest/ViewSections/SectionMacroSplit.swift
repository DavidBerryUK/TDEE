//
//  SectionMacroSplit.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI
import Observation

/// A view section for managing macro split preferences and viewing results.
struct SectionMacroSplit: View {

    @Bindable var macroMix: MacroSplitViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    let calculationResult: CalculatorResultViewModel
    @Binding var path: [AppRoute]
    let proxy: ScrollViewProxy?

    var body: some View {

        UILayoutSectionView(
            title: "Macro Split",
            icon: .macroSplit,
            isExpanded: $sectionManager.macroMixExpanded,
            validationText: "",
            accessibilityId: "sectionMacroSplit",
            sectionId: "sectionMacroSplit",
            sectionSummaryValueView: {
                UISectionSummaryValueMacroMix(macroMix: macroMix, sectionManager: sectionManager)
            },
            editorView: {
                VStack(spacing: 0) {
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
            },
            proxy: proxy
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    @Previewable @State var path: [AppRoute] = []
    SectionMacroSplit(
        macroMix: MacroSplitViewModel(),
        sectionManager: sectionManager,
        calculationResult: CalculatorResultViewModel(),
        path: $path,
        proxy: nil
    )
}
