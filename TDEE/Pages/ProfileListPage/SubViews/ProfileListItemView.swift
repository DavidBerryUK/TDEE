import SwiftUI

/// A single profile row: name with a "Main" badge and an active checkmark, tap to switch,
/// swipe-left to delete (guarded for the Main / last remaining profile).
struct ProfileListItemView: View {
    @Environment(\.palette) private var palette
    @Environment(ProfileStore.self) private var store

    var summary: ProfileSummary
    @Binding var path: [AppRoute]
    /// `.append` when this list lives in the detail stack; `.replaceDetail` for the sidebar's copy.
    var editorPushStyle: EditorPushStyle = .append

    private func pushEditor(_ route: AppRoute) {
        if editorPushStyle == .replaceDetail { path = [route] } else { path.append(route) }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(summary.name)
                .font(.headline)
                .fontWeight(.semibold)

            if summary.isMain {
                Text("Main")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(palette.surface)
                    .foregroundStyle(palette.textSecondary)
                    .clipShape(Capsule())
            }

            if summary.isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(palette.selection)
                    .font(.caption)
            }

            Spacer()
        }
        .padding(16)
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(summary.isActive ? palette.selection.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())  // Make the whole row tappable

        // Tap switches to this profile for the session.
        .onTapGesture {
            store.activate(to: summary.id)
        }

        // Swipe right = edit this profile's name.
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                pushEditor(.profileEditor(item: summary))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }

        // Swipe left = delete (guarded for Main / the last remaining profile).
        .swipeActions(edge: .trailing) {
            if store.canDelete(summary.id) {
                Button(role: .destructive) {
                    Task { await store.delete(id: summary.id) }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    ProfileListItemView(
        summary: ProfileSummary(id: UUID(), name: "Main", isActive: true, isMain: true),
        path: .constant([])
    )
    .environment(ProfileStore())
}
