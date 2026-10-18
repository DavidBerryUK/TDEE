import SwiftUI
import UIKit

/// SwiftUI wrapper for UIActivityViewController
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Exclude activities that don't make sense for calculation results
        // Messages, Mail, Notes, Save to Files, and Copy to Clipboard appear by default;
        // social apps (e.g. Instagram) appear because the share includes an image
        activityVC.excludedActivityTypes = [
            .print,
            .assignToContact,
            .openInIBooks
        ]

        return activityVC
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed - items are set on creation
    }
}

struct ContentView: View {

    @State private var path: [AppRoute] = []

    // Use dependency injection for profile - @State for reference types with @Observable
    @State private var profile: ProfileViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var shareContent: ShareContent?
    @State private var macroCollection: MacroSplitOptionsModelCollection
    @State private var profileStore: ProfileStore

    /// Takes models created once by the owner. This initializer runs on every parent body update,
    /// so creating them here would build (and load, and save) a new ProfileViewModel each time.
    init(profile: ProfileViewModel, macroCollection: MacroSplitOptionsModelCollection, profileStore: ProfileStore) {
        self._profile = State(initialValue: profile)
        self._macroCollection = State(initialValue: macroCollection)
        self._profileStore = State(initialValue: profileStore)
    }

    var body: some View {

        NavigationStack(path: $path) {

            UIMainView(profile: $profile, path: $path) { content in
                shareContent = content
            }

                .navigationTitle(
                    horizontalSizeClass == .compact
                        ? "TDEE"
                        : "Total Daily Energy Expenditure"
                )

                .toolbar {
                    // Quick-switch: choose the active profile for this session (leading, beside the system menu).
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            ForEach(profileStore.profiles) { summary in
                                Button {
                                    profileStore.activate(to: summary.id)
                                } label: {
                                    if summary.isActive {
                                        Label(summary.name, systemImage: "checkmark")
                                    } else {
                                        Text(summary.name)
                                    }
                                }
                            }
                        } label: {
                            Label(profileStore.activeProfile?.name ?? "Profile", systemImage: "person.crop.circle")
                        }
                        .accessibilityLabel("Switch profile")
                        .disabled(profileStore.profiles.isEmpty)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            path.append(.system)
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                        .accessibilityLabel("Open navigation menu")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            path.append(.theme)
                        } label: {
                            Image(systemName: "paintpalette")
                        }
                        .accessibilityLabel("Change theme")
                    }
                }

                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarTitleDisplayMode(.inline)
                .navigationBarTitleDisplayMode(.inline)

                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .system:
                        UISystemPageView(path: $path)
                    case .maintainMacroConfig:
                        MacroOptionsListViewPage(path: $path, selectedMacroId: $profile.selectedMacroId)
                    case .theme:
                        ThemeView()
                    case .about:
                        AboutPage()
                    case .macroEditorCreate:
                        MacroEditViewPage(path: $path, item: nil)
                    case .macroEditorEdit(let item):
                        MacroEditViewPage(path: $path, item: item)
                    case .profiles:
                        ProfileListViewPage(path: $path)
                    case .profileEditor(let item):
                        ProfileEditViewPage(path: $path, item: item)
                    }
                }
        }
        // Inject the global macro collection and profile store for environment access
        .environment(macroCollection)
        .environment(profileStore)
        .task {
            await macroCollection.loadPresets()
            await profileStore.load()
        }
        // Keep the selection valid if the selected macro is deleted or reset away
        .onChange(of: macroCollection.items) { _, items in
            guard !items.isEmpty, !items.contains(where: { $0.id == profile.selectedMacroId }) else { return }
            let fallback = items.first(where: { $0.id == FactoryMacroSplits.Id.balanced }) ?? macroCollection.sortedItems.first
            if let fallback { profile.selectedMacroId = fallback.id }
        }
        .sheet(item: $shareContent) { content in
            ActivityView(items: content.activityItems)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ThemedRoot(themeManager: ThemeManager(defaults: UserDefaults(suiteName: "ContentViewPreview")!)) {
        ContentView(
            profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository),
            macroCollection: MacroSplitOptionsModelCollection(profileRepository: SwiftDataContainer.shared.profileRepository),
            profileStore: ProfileStore(profileRepository: SwiftDataContainer.shared.profileRepository))
    }
}
