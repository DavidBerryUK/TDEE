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

    init() {
        // Initialize with the shared repository for persistence
        let repository = SwiftDataContainer.shared.profileRepository
        self._profile = State(initialValue: ProfileViewModel(profileRepository: repository))
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
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            path.append(.system)
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                        .accessibilityLabel("Open navigation menu")
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
                        MacroEditViewPage(item: nil, onDismissAll: nil)
                    case .macroEditorEdit(let item):
                        // For editing, clear the path to go back to main screen
                        MacroEditViewPage(item: item, onDismissAll: { path.removeAll() })
                    }
                }
        }
        // Inject the global macro collection for environment access
        .environment(MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()))
        .sheet(item: $shareContent) { content in
            ActivityView(items: content.activityItems)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
}
