import SwiftUI

struct MacroOptionsListItemView: View {
    
    @Bindable var item: MacroSplitViewModel
    var onEdit: (MacroSplitViewModel) -> Void
    var onDelete: (MacroSplitViewModel) -> Void
    
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
            onEdit(item)
        }
        // Swipe right = edit
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                onEdit(item)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        
        // Swipe left = delete
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
