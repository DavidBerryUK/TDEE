//
//  UIMacroMixMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 21/10/2026.
//

import SwiftUI

/// The New macro-mix control (story 023, input #13) for compact and regular sizes.
///
/// A neutral, Picker-style `Menu` labelled "Macro Mix" that lists the dynamic preset catalog
/// (`MacroSplitOptionsModelCollection.items`) and rebinds `profile.selectedMacroId` — the Classic
/// wheel picker's selection over a SwiftData-backed, user-editable catalog, surfaced as a dropdown
/// with a checkmark on the current preset. It mirrors `UIActivityLevelMenuButtonView` (the neutral
/// menu) but iterates the environment collection instead of a fixed enum, and takes a Picker-style
/// menu (a checkmark on the selection) rather than plain buttons — the owner's choice for a selection
/// over a dynamic list. It reads the collection from the environment so it tracks preset edits /
/// additions, and replaces `SectionEditorMacroMix` (the wheel) without touching it — see
/// `SectionMacroSplit`.
struct UIMacroMixMenuButtonView: View {

    @Bindable var profile: ProfileViewModel
    @Environment(MacroSplitOptionsModelCollection.self) private var collection

    var body: some View {
        Menu {
            Picker("Macro Split", selection: $profile.selectedMacroId) {
                ForEach(collection.items) { item in
                    Text(item.name)
                        .tag(item.id)
                }
            }
        } label: {
            Text("Macro Mix")
        }
        .accessibilityIdentifier("macroMixMenu")
    }
}

#Preview {
    let collection = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
    return UIMacroMixMenuButtonView(profile: ProfileViewModel())
        .environment(collection)
}
