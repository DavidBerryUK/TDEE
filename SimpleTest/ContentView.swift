import SwiftUI

struct ContentView: View {

    @State private var path: [AppRoute] = []

    // Use dependency injection for profile - @State for reference types with @Observable
    @State private var profile: ProfileViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init() {
        // Initialize with the shared repository for persistence
        let repository = SwiftDataContainer.shared.profileRepository
        self._profile = State(initialValue: ProfileViewModel(profileRepository: repository))
    }

    var body: some View {

        NavigationStack(path: $path) {

            UIMainView(profile: $profile, path: $path)

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
                        MacroEditViewPage(item: nil)
                    case .macroEditorEdit(let item):
                        MacroEditViewPage(item: item)
                    }
                }
        }
        // Inject the global macro collection for environment access
        .environment(MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()))
    }
}

#Preview {
    ContentView()
}
