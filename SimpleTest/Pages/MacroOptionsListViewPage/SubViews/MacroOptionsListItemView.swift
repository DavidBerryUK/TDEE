import SwiftUI

struct MacroOptionsListItemView: View {
    
    @Environment(MacroSplitViewModelCollection.self)
    var collection
    
    @Bindable var item: MacroSplitViewModel
    @Binding var path: [EnumAppRoute]
    
    func handleOnDelete (item: MacroSplitViewModel) {
        collection.remove(item)
    }
    
    func handleOnEdit (item: MacroSplitViewModel) {
        path.append(.macroEditorEdit(item))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Title row
            HStack {
                Text(item.name)
                    .font(.body)
                Text("\(item.ordinal)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()        
            }
            
            // Macro bar
            MacroInformationBarView(item:item)
            MacroInformationTextView(item: item)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        
        // detect the user tapping on the row
        .onTapGesture {
            handleOnEdit(item: item)
        }
        // Swipe right = edit
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                handleOnEdit(item: item)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        
        // Swipe left = delete
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                handleOnDelete(item: item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
