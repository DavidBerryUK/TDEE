//
//  UISectionSummaryCalorieAdjustment.swift
//  TDEE
//
//  Created by David Berry on 10/04/2026.
//

import SwiftUI

struct UISectionSummaryValueMacroMix: View {
    @Environment(\.palette) private var palette

    @Bindable var profile: ProfileViewModel
    @Bindable var sectionManager : SectionManagerViewModel
    @Environment(MacroSplitOptionsModelCollection.self) private var collection

    /// In New mode the preset name also lives in the editor's menu button, so — while the section is
    /// expanded — this header summary hides itself to keep the name ("Balanced") from showing twice.
    /// Collapsed, the menu button is off-screen, so the summary is the at-a-glance value and stays;
    /// Classic mode (wheel picker) passes `false` and always shows it.
    var hideWhenExpanded: Bool = false

    private var displayText: String {
        let selectedOption = collection.items.first { $0.id == profile.selectedMacroId }
        if let selectedOption = selectedOption {
            return selectedOption.name
        } else {
            return "No selection"
        }
    }

    var body: some View {
        // New + expanded: the editor's menu button owns the value, so hide the header echo to avoid a
        // duplicate "Balanced". Collapsed, or Classic mode, the summary is the sole value display.
        if hideWhenExpanded && sectionManager.macroMixExpanded {
            EmptyView()
        } else {
            HStack {
                Text(displayText)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: sectionManager.macroMixExpanded)
                    .foregroundColor(UITextStyleResolver.fontColor(palette, isExpanded: sectionManager.macroMixExpanded))
                    .fontWeight(UITextStyleResolver.fontWeight(isExpanded: sectionManager.macroMixExpanded))
                    .accessibilityLabel("Selected macro mix")
                    .accessibilityValue(displayText)
            }
            .transition(.opacity)
        }
    }
}
#Preview {
    let collection = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
    let profile = ProfileViewModel()
    let sectionManager = SectionManagerViewModel()
    return UISectionSummaryValueMacroMix(profile: profile, sectionManager: sectionManager)
        .environment(collection)
}
