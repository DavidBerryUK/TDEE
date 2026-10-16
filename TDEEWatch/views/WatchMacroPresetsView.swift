//
//  WatchMacroPresetsView.swift
//  TDEE Watch
//

import SwiftUI

/// Pick the macro split to use. Custom presets are created on the iPhone.
struct WatchMacroPresetsView: View {
    @Bindable var profile: ProfileViewModel
    let macroCollection: MacroSplitOptionsModelCollection
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(macroCollection.sortedItems) { item in
            Button {
                profile.selectedMacroId = item.id
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                        // Letters as well as colour, so the split reads without colour vision
                        HStack(spacing: 6) {
                            Text("P \(item.protein)").foregroundStyle(WatchPalette.macroProtein)
                            Text("C \(item.carbs)").foregroundStyle(WatchPalette.macroCarbs)
                            Text("F \(item.fats)").foregroundStyle(WatchPalette.macroFat)
                        }
                        .font(.caption2)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Protein \(item.protein)%, carbs \(item.carbs)%, fats \(item.fats)%")
                    }
                    Spacer()
                    if item.id == profile.selectedMacroId {
                        Image(systemName: "checkmark")
                            .foregroundStyle(WatchPalette.selection)
                    }
                }
            }
            .accessibilityAddTraits(item.id == profile.selectedMacroId ? .isSelected : [])
        }
        .navigationTitle("Macros")
    }
}
