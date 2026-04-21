import SwiftUI

// MARK: - Route Enum

struct ContentView: View {
    @State private var path: [EnumAppRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            MainView()
                .navigationTitle("Main")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            path.append(.system)
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .navigationDestination(for: EnumAppRoute.self) { route in
                    switch route {
                    case .system:
                        SystemPage(path: $path)
                    case .maintainMacroConfig:
                        MaintainMacroConfigView()
                    case .theme:
                        ThemeView()
                    case .about:
                        AboutPage()
                    }
                }
        }
    }
}


#Preview {
    ContentView()
}
