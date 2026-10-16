//
//  SectionEditorMacroMix.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains UI components that must remain as wheel pickers for macro selection.
// Changing picker styles alters the user experience.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct SectionEditorMacroMix: View {

    @Environment(MacroSplitOptionsModelCollection.self) private var collection
    @Bindable var profile: ProfileViewModel

    var body: some View {

        var selectedOption: MacroSplitOptionModel? {
            collection.items.first { $0.id == profile.selectedMacroId }
        }

        VStack {
            UIWheelPickerMacroMixView(profile: profile)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    let collection = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
    return SectionEditorMacroMix(profile: ProfileViewModel())
        .environment(collection)
}
