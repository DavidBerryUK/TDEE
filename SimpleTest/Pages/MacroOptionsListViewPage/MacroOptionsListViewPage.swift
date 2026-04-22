import SwiftUI



struct MacroOptionsListViewPage: View {
    
    @Environment(MacroSplitViewModelCollection.self)
    var collection
    
    @Binding var path: [EnumAppRoute]
    
    //
    // move these into a collection handler
    //
    func handleOnEdit (item: MacroSplitViewModel)  {
        path.append(.macroEditorEdit(item))
    }
    
    func handleOnDelete (item: MacroSplitViewModel) {
        collection.remove(item)
    }
    
    func handleOnSave(item: MacroSplitViewModel) {
        collection.update(item)
    }
    
    //
    //
    //
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    //
                    // list items using a sub view for readability
                    //
                    ForEach(collection.sortedItems, id: \.id) { item in
                        MacroOptionsListItemView( item: item, path: $path)
//                            onEdit: { item in handleOnEdit(item: item) },
//                            onDelete: { item in handleOnDelete(item: item) }
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
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(.macroEditorCreate)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            MacroOptionsListInstructions()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Maintain Macros (1)")
    }
}
