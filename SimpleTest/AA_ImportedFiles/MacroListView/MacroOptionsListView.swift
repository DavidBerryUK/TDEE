import SwiftUI

struct MacroOptionsListView: View {
    
    @Environment(MacroSplitViewModelCollection.self)
    var collection
    
    @State private var editingItem: MacroSplitViewModel?
    
    //
    // move these into a collection handler
    //
    func handleOnEdit (item: MacroSplitViewModel)  {
        editingItem = item
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
        //NavigationStack {
            ZStack(alignment: .bottom) {
                
                List {
                    Section {
                        //
                        // list items using a sub view for readability
                        //
                        ForEach(collection.sortedItems, id: \.id) { item in
                            MacroOptionsListItemView(
                                item: item,
                                onEdit: {item in handleOnEdit(item: item) },
                                onDelete: {item in handleOnDelete(item: item) }
                            )
                                
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
//                 .navigationTitle("Macros")
                
                
                // State-driven navigation:
                // When `editingItem` is set (non-nil), SwiftUI pushes MacroEditView.
                // When it becomes nil (e.g. back button), the view is popped.
                // This replaces NavigationLink and allows tap/swipe/actions to drive navigation.
//                .navigationDestination(item: $editingItem) { item in
//                    MacroEditView(
//                        item: item,
//                        onSave: { updated in handleOnSave(item: updated) },
//                        onDelete: {handleOnDelete(item: item)}
//                    )
//                }
                MacroOptionsListInstructions()
            }
        }
    }
//}
