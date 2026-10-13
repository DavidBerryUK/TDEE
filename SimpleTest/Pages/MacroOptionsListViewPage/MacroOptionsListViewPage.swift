import SwiftUI

struct MacroOptionsListViewPage: View {

    @Environment(MacroSplitOptionsModelCollection.self)
    var collection

    @Binding var path: [AppRoute]

    //
    // move these into a collection handler
    //
    func handleOnEdit(item: MacroSplitOptionModel) {
        // Mark this item as selected when editing
        collection.selectItem(byId: item.id)
        path.append(.macroEditorEdit(item))
    }

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
                        MacroOptionsListCardView(item: item, path: $path)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onMove { source, destination in
                        collection.move(from: source, to: destination)
                    }
                }

                // Spacer so last row isn't hidden behind footer
                Color.clear
                    .frame(height: 40)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .onAppear {
                collection.selectFirstItem()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
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
        path: .constant([])
    )
    .environment(MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()))
}
