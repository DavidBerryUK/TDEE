import SwiftUI

struct MacroOptionsListItemView: View {
    @Environment(\.palette) private var palette
    
    @Environment(MacroSplitOptionsModelCollection.self)
    var collection
    
    @Bindable var item: MacroSplitOptionModel
    @Binding var path: [AppRoute]
    
    func handleOnDelete (item: MacroSplitOptionModel) {
        collection.remove(item)
    }
    
    func handleOnEdit (item: MacroSplitOptionModel) {
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
                    .foregroundStyle(palette.textSecondary)
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
