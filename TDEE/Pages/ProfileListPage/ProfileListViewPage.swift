import SwiftUI

/// The profile list: every stored profile by name, the active one marked, with an "Add"
/// button to create and tap-to-switch. Mirrors `MacroOptionsListViewPage`.
struct ProfileListViewPage: View {

    @Environment(ProfileStore.self) private var store
    @Binding var path: [AppRoute]
    /// `.append` when this list lives in the detail stack; `.replaceDetail` for the sidebar's copy.
    var editorPushStyle: EditorPushStyle = .append

    /// Push an editor the way this list's context expects (append, or reset the detail to the editor).
    private func pushEditor(_ route: AppRoute) {
        if editorPushStyle == .replaceDetail { path = [route] } else { path.append(route) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                List {
                    SwiftUI.Section {
                        ForEach(store.profiles) { summary in
                            ProfileListItemView(summary: summary, path: $path, editorPushStyle: editorPushStyle)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .id(summary.id)
                        }
                    }

                    // Spacer so last row isn't hidden behind footer
                    Color.clear
                        .frame(height: 40)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .onAppear {
                    // Keep the active profile scrolled into view.
                    if let active = store.activeProfile {
                        Task {
                            try? await Task.sleep(nanoseconds: 100_000_000) // Small delay for UI to render
                            proxy.scrollTo(active.id, anchor: .center)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            pushEditor(.profileEditor(item: nil))
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Add")
                            }
                        }
                        .accessibilityLabel("Add profile")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Profiles")
    }
}

#Preview {
    NavigationStack {
        ProfileListViewPage(path: .constant([]))
    }
    .environment(ProfileStore())
}
