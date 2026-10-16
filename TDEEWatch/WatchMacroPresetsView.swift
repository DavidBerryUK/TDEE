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
                        HStack(spacing: 6) {
                            Text("\(item.protein)%").foregroundStyle(WatchPalette.macroProtein)
                            Text("\(item.carbs)%").foregroundStyle(WatchPalette.macroCarbs)
                            Text("\(item.fats)%").foregroundStyle(WatchPalette.macroFat)
                        }
                        .font(.caption2)
                    }
                    Spacer()
                    if item.id == profile.selectedMacroId {
                        Image(systemName: "checkmark")
                            .foregroundStyle(WatchPalette.selection)
                    }
                }
            }
        }
        .navigationTitle("Macros")
    }
}
