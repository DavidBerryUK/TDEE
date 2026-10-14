//
//  UIWheelPickerMacroMixView.swift
//  SimpleTest
//
//  Created by David Berry on 25/04/2026.
//

import SwiftUI

struct UIWheelPickerMacroMixView: View {

    @Bindable var profile: ProfileViewModel
    @Environment(MacroSplitOptionsModelCollection.self) private var collection

    var body: some View {
        Picker("Macro Split", selection: $profile.selectedMacroId) {
            ForEach(collection.items) { item in
                Text(item.name)
                    .tag(item.id)
            }
        }
        .pickerStyle(.wheel)
        .accessibilityIdentifier("macroSplitPicker")
    }
}
