import SwiftUI


struct ContentView: View {
    @State private var path: [EnumAppRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            UIMainView()
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
