import SwiftUI

struct MacroEditViewPage: View {
    @Environment(\.dismiss) private var dismiss
    
    @Environment(MacroSplitOptionsModelCollection.self)
    var collection
    
    @Binding var path: [EnumAppRoute]
    @State private var editMacro: MacroSplitOptionModel
    @State private var showDeleteSheet = false
    
    var isNew: Bool
    
    
//    var onSave: (MacroSplitViewModel) -> Void
//    var onDelete: (() -> Void)? = nil
    
//    func handleOnDelete(item: MacroSplitViewModel) {
//        collection.remove(item)
//    }
//    
//    func handleOnSave(item: MacroSplitViewModel) {
//        collection.update(item)
//    }
    
    init(
        path: Binding<[EnumAppRoute]> = .constant([]),
        item: MacroSplitOptionModel? = nil
    ) {
        self._path = path
        self.isNew = (item == nil)
        self._editMacro = State(initialValue: (item == nil) ? MacroSplitOptionModel() : item!.clone())
    }
    
    // MARK: - Actions
    
    private func handleOnDelete() {
        
            collection.remove(editMacro)
            dismiss()
        
    }
    
    // MARK: - View
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $editMacro.name)
            }
            
            Section("Macros (%)") {
                UISliderMacroMixView(model: editMacro)
            }
            
            if isNew {
                Section {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cancel")
                                .font(.body.weight(.semibold))
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    .foregroundStyle(.primary)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
            } else {
                
                    Section {
                        Button(role: .destructive) {
                            showDeleteSheet = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("Delete", systemImage: "trash")
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(.vertical, 10)
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                
            }
        }
        .navigationTitle("Edit Macro")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    collection.update(editMacro)
                    dismiss()
                }
                .disabled(
                    editMacro.name.isEmpty ||
                    (editMacro.protein + editMacro.carbs + editMacro.fats) != 100
                )
            }
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteConfirmationSheet(
                onConfirm: {
                    showDeleteSheet = false
                    collection.remove(editMacro)
                },
                onCancel: {
                    showDeleteSheet = false
                }
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        
        }
    }
}

// MARK: - Confirmation Sheet

struct DeleteConfirmationSheet: View {
    
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "trash")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.red)
            }
            .padding(.top, 8)
            
            // Title + message
            VStack(spacing: 6) {
                Text("Delete Macro?")
                    .font(.headline)
                
                Text("This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            
            // Actions
            VStack(spacing: 10) {
                
                Button(role: .destructive) {
                    onConfirm()
                } label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .font(.body.weight(.semibold))
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .font(.body.weight(.semibold))
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

#Preview {
    NavigationStack {
        MacroEditViewPage(path: .constant([]))
    }
}
