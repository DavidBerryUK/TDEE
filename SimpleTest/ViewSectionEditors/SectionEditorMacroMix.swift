//
//  SectionEditorMacroMix.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

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
