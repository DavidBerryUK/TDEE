//
//  UIWheelPickerMacroMixView.swift
//  SimpleTest
//
//  Created by David Berry on 25/04/2026.
//

import SwiftUI

struct UIWheelPickerMacroMixView: View {

    @Bindable var macroSplit: MacroSplitViewModel
    @Environment(MacroSplitOptionsModelCollection.self) private var collection

    var body: some View {
        Picker("Macro Split", selection: $macroSplit.selectedMacroId) {
            ForEach(collection.items) { item in
                Text(item.name)
                    .tag(item.id)
            }
        }
        .pickerStyle(.wheel)
        .accessibilityLabel("Macro split selection")
        .accessibilityValue("Selected: \(collection.items.first { $0.id == macroSplit.selectedMacroId }?.name ?? "None")")
    }
}

private struct UIWheelPickerMacroMixPreviewHost: View {
    let collection: MacroSplitOptionsModelCollection
    @State private var macroSplit: MacroSplitViewModel
    
    init(collection: MacroSplitOptionsModelCollection) {
        self.collection = collection
        _macroSplit = State(
            initialValue: MacroSplitViewModel()
        )
    }
    
    var body: some View {
        UIWheelPickerMacroMixView(macroSplit: macroSplit)
            .environment(collection)
    }
}

#Preview {
    let collection = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
    UIWheelPickerMacroMixPreviewHost(collection: collection)
}
