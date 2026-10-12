import SwiftUI

struct ContentView: View {

    @State private var path: [EnumAppRoute] = []

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {

        NavigationStack(path: $path) {

            UIMainView(path: $path)

                .safeAreaPadding(.top, 100)

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
                .ignoresSafeArea(edges: .top)

                .navigationDestination(for: EnumAppRoute.self) { route in
                    switch route {
                    case .system:
                        UISystemPageView(path: $path)
                    case .maintainMacroConfig:
                        MacroOptionsListViewPage(path: $path)
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
    }
}

#Preview {
    ContentView()
}
