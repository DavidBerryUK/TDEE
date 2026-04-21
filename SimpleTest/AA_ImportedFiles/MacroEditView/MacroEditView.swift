import SwiftUI

struct MacroEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var editMacro: MacroSplitViewModel
    @State private var showDeleteSheet = false
    
    var isNew: Bool
    var onSave: (MacroSplitViewModel) -> Void
    var onDelete: (() -> Void)? = nil
    
    init(
        item: MacroSplitViewModel? = nil,
        onSave: @escaping (MacroSplitViewModel) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.isNew = (item == nil)
        self._editMacro = State(initialValue:
                                    (item == nil) ? MacroSplitViewModel() : item!.clone()
        )
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    // MARK: - Actions
    
    private func handleOnDelete() {
        if !isNew, let onDelete {
            onDelete()
            dismiss()
        }
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
                if onDelete != nil {
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
        }
        .navigationTitle("Edit Macro")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    onSave(editMacro)
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
                    handleOnDelete()
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
        MacroEditView { _ in }
    }
}
