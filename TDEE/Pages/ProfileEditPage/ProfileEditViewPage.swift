import SwiftUI

/// Create or rename a profile, with a guarded delete. Mirrors `MacroEditViewPage`:
/// a Name field, a Cancel/Save toolbar, and a destructive delete confirmation.
///
/// The Main profile's name is fixed (it's the identifier), so editing it locks the Name field
/// and offers only delete. A non-Main profile can be renamed, but not to "Main" nor to a name
/// another profile already uses.
struct ProfileEditViewPage: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @Environment(ProfileStore.self) private var store
    @Environment(\.palette) private var palette

    @Binding var path: [AppRoute]
    @State private var name: String
    @State private var showDeleteSheet = false

    var isNew: Bool
    var existingId: UUID?

    init(path: Binding<[AppRoute]> = .constant([]), item: ProfileSummary? = nil) {
        self._path = path
        self.isNew = (item == nil)
        self.existingId = item?.id
        self._name = State(initialValue: item?.name ?? "")
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isEditingMain: Bool {
        store.profiles.first(where: { $0.id == existingId })?.isMain ?? false
    }

    private var nameCollides: Bool {
        store.profiles.contains { $0.id != existingId && $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !nameCollides && !isEditingMain
    }

    private var canDelete: Bool {
        guard let id = existingId else { return false }
        return store.canDelete(id)
    }

    // MARK: - Actions

    private func save() {
        Task {
            if isNew {
                await store.add(name: trimmedName)
            } else if let id = existingId {
                await store.rename(id: id, to: trimmedName)
            }
            dismiss()
        }
    }

    private func delete() {
        guard let id = existingId else { return }
        Task {
            await store.delete(id: id)
            dismiss()
        }
    }

    // MARK: - View

    var body: some View {
        Form {
            SwiftUI.Section("Name") {
                TextField("Name", text: $name)
                    .textContentType(.username)
                    .disabled(isEditingMain)
                    .listRowBackground(palette.surface)
            }

            if isNew {
                SwiftUI.Section {
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
                    .foregroundStyle(palette.text)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
            } else {
                SwiftUI.Section {
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
                    .disabled(!canDelete)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.1))
                    )
                }
            }
        }
        .themedGroupedList(palette)
        .navigationTitle(isNew ? "Add Profile" : "Edit Profile")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
                .disabled(!canSave)
            }
        }
        .sheet(isPresented: $showDeleteSheet) {
            ProfileDeleteConfirmationSheet(
                onConfirm: {
                    showDeleteSheet = false
                    delete()
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

struct ProfileDeleteConfirmationSheet: View {
    @Environment(\.palette) private var palette

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
                Text("Delete Profile?")
                    .font(.headline)

                Text("This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundStyle(palette.textSecondary)
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
                        .foregroundStyle(palette.text)
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
        ProfileEditViewPage(path: .constant([]))
    }
    .environment(ProfileStore())
}
