//
//  UIWheelPickerMacroMixView.swift
//  TDEE
//
//  Created by David Berry on 25/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a wheel picker for macro split selection.
// The .pickerStyle(.wheel) is intentional - wheel pickers are best for ordered categorical values.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

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
