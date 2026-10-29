//
//  UIMacroMixMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 21/10/2026.
//

import SwiftUI

/// The New macro-mix control (story 023, input #13) for compact and regular sizes.
///
/// A Picker-style `Menu` whose label is the current preset's name plus a selector chevron, that lists
/// the dynamic preset catalog (`MacroSplitOptionsModelCollection.items`) and rebinds
/// `profile.selectedMacroId` — the Classic wheel picker's selection over a SwiftData-backed,
/// user-editable catalog, surfaced as a dropdown with a checkmark on the current preset. The full
/// name and chevron make the control read as a value picker, the discoverability fix for the old
/// neutral "Macro Mix" label (Decision 10), mirroring `UIActivityLevelMenuButtonView` / the UoM
/// switchers. It differs from those in two ways that are intentional: it iterates the environment
/// collection instead of a fixed enum, and takes a Picker-style menu (a checkmark on the selection)
/// rather than plain buttons — the owner's choice for a selection over a dynamic list. It reads the
/// collection from the environment so it tracks preset edits / additions, and replaces
/// `SectionEditorMacroMix` (the wheel) without touching it — see `SectionMacroSplit`.
struct UIMacroMixMenuButtonView: View {

    @Bindable var profile: ProfileViewModel
    @Environment(MacroSplitOptionsModelCollection.self) private var collection

    /// The current preset's name, or a fallback when the selection matches no preset — the same lookup
    /// `UISectionSummaryValueMacroMix` uses for its collapsed summary, so the label and the summary
    /// always agree.
    private var selectedPresetName: String {
        collection.items.first { $0.id == profile.selectedMacroId }?.name ?? "No selection"
    }

    var body: some View {
        Menu {
            Picker("Macro Split", selection: $profile.selectedMacroId) {
                ForEach(collection.items) { item in
                    Text(item.name)
                        .tag(item.id)
                }
            }
        } label: {
            // Current preset name + a selector chevron, so the control reads as a value picker.
            HStack(spacing: 4) {
                Text(selectedPresetName)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("macroMixMenu")
    }
}

#Preview {
    let collection = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
    return UIMacroMixMenuButtonView(profile: ProfileViewModel())
        .environment(collection)
}
