import SwiftUI


struct ContentView: View {
    @State private var path: [EnumAppRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            UIMainView()
                .safeAreaPadding(.top, 100) // push view down so it is visible below the navigation bar
                .navigationTitle(
                    EnumDevice.isSmallScreen
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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {

                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share current settings")
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar(.visible, for: .navigationBar)
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
