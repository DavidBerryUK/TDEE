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
    @Environment(MacroSplitOptionsModelCollection.self) private var collection

    private var displayText: String {
        let selectedOption = collection.items.first { $0.id == macroMix.selectedMacroId }
        if let selectedOption = selectedOption {
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
#Preview {
    let collection = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
    let macroMix = MacroSplitViewModel()
    let sectionManager = SectionManagerViewModel()
    return UISectionSummaryValueMacroMix(macroMix: macroMix, sectionManager: sectionManager)
        .environment(collection)
}
