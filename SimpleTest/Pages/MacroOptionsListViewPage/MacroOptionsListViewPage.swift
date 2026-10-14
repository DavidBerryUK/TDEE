import SwiftUI

struct MacroOptionsListViewPage: View {

    @Environment(MacroSplitOptionsModelCollection.self)
    var collection

    @Binding var path: [AppRoute]
    @Binding var selectedMacroId: UUID

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
            List {
                SwiftUI.Section {
                    //
                    // list items using a sub view for readability
                    //
                    ForEach(collection.sortedItems, id: \.id) { item in
                        MacroOptionsListCardView(item: item, path: $path, selectedMacroId: $selectedMacroId)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
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
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(.macroEditorCreate)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add")
                        }
                    }
                }
            }
            MacroOptionsListInstructions()
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
