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
                Button { path.append(.maintainMacroConfig) } label: {
                    Label("Maintain Macro Config", systemImage: "fork.knife")
                }
                .accessibilityLabel("Open macro configuration settings")
                .accessibilityValue("Navigate to macro configuration")
                Button { path.append(.profiles) } label: {
                    Label("Profiles", systemImage: "person.crop.circle")
                }
                .accessibilityLabel("Manage profiles")
                .accessibilityValue("Navigate to profiles")
                Button { path.append(.theme) } label: {
                    Label("Theme", systemImage: "paintpalette")
                }
                .accessibilityLabel("Change application theme")
                .accessibilityValue("Navigate to theme settings")
                Button { path.append(.inputMethod) } label: {
                    Label("Input Method", systemImage: "keyboard")
                }
                .accessibilityLabel("Change input method settings")
                .accessibilityValue("Navigate to input method settings")
                Button { path.append(.about) } label: {
                    Label("About", systemImage: "info.circle")
                }
                .accessibilityLabel("View about information")
                .accessibilityValue("Navigate to about page")
            }
            .listRowBackground(palette.surface)
            SwiftUI.Section("Data") {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset Macro Presets to Defaults", systemImage: "trash")
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
