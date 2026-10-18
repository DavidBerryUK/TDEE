//
//  SystemPage.swift
//  TDEE
//
//  Created by David Berry on 21/04/2026.
//
import SwiftUI

struct UISystemPageView: View {
    @Environment(MacroSplitOptionsModelCollection.self) private var collection
    @Environment(\.palette) private var palette
    @Binding var path: [AppRoute]
    @State private var showResetConfirmation = false

    var body: some View {
        List {
            SwiftUI.Section("Navigation") {
                Button("Maintain Macro Config") { path.append(.maintainMacroConfig) }
                    .accessibilityLabel("Open macro configuration settings")
                    .accessibilityValue("Navigate to macro configuration")
                Button("Profiles") { path.append(.profiles) }
                    .accessibilityLabel("Manage profiles")
                    .accessibilityValue("Navigate to profiles")
                Button("Theme") { path.append(.theme) }
                    .accessibilityLabel("Change application theme")
                    .accessibilityValue("Navigate to theme settings")
                Button("About") { path.append(.about) }
                    .accessibilityLabel("View about information")
                    .accessibilityValue("Navigate to about page")
            }
            .listRowBackground(palette.surface)
            SwiftUI.Section("Data") {
                Button("Reset Macro Presets to Defaults", role: .destructive) {
                    showResetConfirmation = true
                }
                .accessibilityLabel("Reset macro presets to defaults")
            }
            .listRowBackground(palette.surface)
        }
        .confirmationDialog(
            "Reset all macro presets to their defaults? Custom and edited presets will be lost.",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset to Defaults", role: .destructive) {
                Task { await collection.resetToDefaults() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .themedGroupedList(palette)
        .navigationTitle("System")
    }
}
