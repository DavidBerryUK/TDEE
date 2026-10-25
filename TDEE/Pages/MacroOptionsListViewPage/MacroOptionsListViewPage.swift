import SwiftUI

struct MacroOptionsListViewPage: View {

    @Environment(MacroSplitOptionsModelCollection.self)
    var collection

    @Binding var path: [AppRoute]
    @Binding var selectedMacroId: UUID
    /// `.append` when this list lives in the detail stack; `.replaceDetail` for the sidebar's copy.
    var editorPushStyle: EditorPushStyle = .append

    /// Push an editor the way this list's context expects (append, or reset the detail to the editor).
    private func pushEditor(_ route: AppRoute) {
        if editorPushStyle == .replaceDetail { path = [route] } else { path.append(route) }
    }

    //
    // move these into a collection handler
    //
    func handleOnDelete(item: MacroSplitOptionModel) {
        collection.remove(item)
    }

    func handleOnSave(item: MacroSplitOptionModel) {
        collection.update(item)
    }

    //
    //
    //
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                List {
                    SwiftUI.Section {
                        //
                        // list items using a sub view for readability
                        //
                        ForEach(collection.sortedItems, id: \.id) { item in
                            MacroOptionsListCardView(item: item, path: $path, selectedMacroId: $selectedMacroId, editorPushStyle: editorPushStyle)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .id(item.id)
                        }
                    }

                    // Spacer so last row isn't hidden behind footer
                    Color.clear
                        .frame(height: 40)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .onAppear {
                    // Select the current profile's macro selection instead of always the first item
                    collection.selectItem(byId: selectedMacroId)
                    // Scroll the selected item into view
                    Task {
                        try? await Task.sleep(nanoseconds: 100_000_000) // Small delay for UI to render
                        proxy.scrollTo(selectedMacroId, anchor: .center)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        pushEditor(.macroEditorCreate)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Maintain Macros")
    }
}

#Preview {
    MacroOptionsListViewPage(
        path: .constant([]),
        selectedMacroId: .constant(FactoryMacroSplits.Id.balanced)
    )
    .environment(MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()))
}
