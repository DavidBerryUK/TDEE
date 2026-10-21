//
//  SectionMacroSplit.swift
//  TDEE
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI
import Observation

/// A view section for managing macro split preferences and viewing results.
struct SectionMacroSplit: View {
    @Environment(\.palette) private var palette

    @Bindable var profile: ProfileViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    let calculationResult: CalculatorResultViewModel
    @Binding var path: [AppRoute]
    let proxy: ScrollViewProxy?

    @Environment(MacroSplitOptionsModelCollection.self) private var macroCollection
    // Story 023, input #13 — the per-input Classic/New toggle that routes the selector below.
    @Environment(InputStyleManager.self) private var inputStyle

    var body: some View {

        UILayoutSectionView(
            title: "Macro Split",
            icon: .macroSplit,
            isExpanded: $sectionManager.macroMixExpanded,
            validationText: "",
            accessibilityId: "sectionMacroSplit",
            sectionId: "sectionMacroSplit",
            sectionSummaryValueView: {
                UISectionSummaryValueMacroMix(profile: profile, sectionManager: sectionManager)
            },
            editorView: {
                VStack(spacing: 0) {
                    // Story 023, input #13 — a single toggle (no gate): any "New" swaps only the wheel
                    // for the neutral menu; the result cards and the Customise / Edit Presets buttons stay
                    // unchanged. The Classic path (SectionEditorMacroMix / UIWheelPickerMacroMixView) is
                    // left untouched.
                    if inputStyle.style(for: .macroMix) == .new {
                        UIMacroMixMenuButtonView(profile: profile)
                    } else {
                        SectionEditorMacroMix(profile: profile)
                    }
                    SectionMacroMixResults(calculationResults: calculationResult)
                        .padding(.top, Spacing.medium)
                        .padding(.bottom, Spacing.small)

                    HStack {
                        // Customise button - Edit Current Macro
                        Button("Customise") {
                            // Navigate directly to edit the currently selected macro
                            if let currentMacro = macroCollection.items.first(where: { $0.id == profile.selectedMacroId }) {
                                path.append(.macroEditorEdit(currentMacro))
                            }
                        }
                        .foregroundColor(palette.primary)
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal)

                        // Edit Presets button - Manage Presets
                        Button("Edit Presets") {
                            // Navigate to full list
                            path.append(.maintainMacroConfig)
                        }
                        .foregroundColor(palette.primary)
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                    }
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
        profile: ProfileViewModel(),
        sectionManager: sectionManager,
        calculationResult: CalculatorResultViewModel(),
        path: $path,
        proxy: nil
    )
}
