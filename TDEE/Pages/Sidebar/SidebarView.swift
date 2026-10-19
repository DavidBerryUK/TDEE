//
//  SidebarView.swift
//  TDEE
//
//  iPad adaptation (story-022).
//

import SwiftUI

/// The screens the iPad master (sidebar) can drill into.
enum MasterDestination: Hashable {
    case profiles
    case macros
    case theme
    case inputMethod
    case about
}

/// The iPad (regular size class) master: a drill-down menu.
///
/// Selecting a destination pushes its screen onto *this* column (a back arrow returns to the menu).
/// The macro / profile lists live here; their add/edit opens in the detail via the shared `path`,
/// so an editor slides into the detail while the list stays in the master.
struct SidebarView: View {
    @Environment(\.palette) private var palette
    @Environment(MacroSplitOptionsModelCollection.self) private var macroCollection

    @Binding var path: [AppRoute]
    @Binding var selectedMacroId: UUID

    @State private var masterPath: [MasterDestination] = []
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack(path: $masterPath) {
            menuRoot
                .navigationDestination(for: MasterDestination.self) { destination in
                    switch destination {
                    case .profiles:
                        ProfileListViewPage(path: $path)
                    case .macros:
                        MacroOptionsListViewPage(path: $path, selectedMacroId: $selectedMacroId)
                    case .theme:
                        ThemeView()
                    case .inputMethod:
                        InputMethodView()
                    case .about:
                        AboutPage()
                    }
                }
        }
        .navigationTitle("TDEE")
    }

    /// The top-level menu. "Main" returns to this menu (pops the master to its root); the others
    /// drill into their screen. The *Data* action keeps Reset reachable on iPad.
    private var menuRoot: some View {
        List {
            SwiftUI.Section("Navigate") {
                // Home: return to this menu.
                Button {
                    masterPath = []
                } label: {
                    Label("Main", systemImage: "house")
                }

                NavigationLink(value: MasterDestination.profiles) {
                    Label("Profiles", systemImage: "person.crop.circle")
                }
                NavigationLink(value: MasterDestination.macros) {
                    Label("Macro Config", systemImage: "fork.knife")
                }
                NavigationLink(value: MasterDestination.theme) {
                    Label("Theme", systemImage: "paintpalette")
                }
                NavigationLink(value: MasterDestination.inputMethod) {
                    Label("Input Method", systemImage: "keyboard")
                }
                NavigationLink(value: MasterDestination.about) {
                    Label("About", systemImage: "info.circle")
                }
            }

            SwiftUI.Section("Data") {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Text("Reset Macro Presets to Defaults")
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
                Task { await macroCollection.resetToDefaults() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    ThemedRoot(themeManager: ThemeManager(defaults: UserDefaults(suiteName: "SidebarViewPreview")!)) {
        SidebarView(path: .constant([]), selectedMacroId: .constant(FactoryMacroSplits.Id.balanced))
    }
    .environment(MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()))
    .environment(ProfileStore())
}
