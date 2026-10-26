//
//  NoticeBanner.swift
//  TDEE
//
//  Created by David Berry on 25/10/2026.
//

import SwiftUI

/// A transient, non-blocking banner for a failed macro-preset operation (PA-31).
///
/// Surfaces `MacroSplitOptionsModelCollection.notice` when a preset load, reset, save or delete
/// fails to persist. It never halts the app: the user keeps working, and the banner clears on tap
/// or after a few seconds. Deliberately **animation-free** — it snaps in and out so no
/// `.transition` / `.animation` parameter is introduced (see `UI_RESTRICTIONS.md`).
struct NoticeBanner: View {
    let message: String
    var onDismiss: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(palette.primary)
                .accessibilityHidden(true)

            Text(message)
                .font(.footnote)
                .foregroundStyle(palette.text)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(palette.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(palette.surface)
        .overlay(alignment: .bottom) {
            Divider()
        }
        // Auto-dismiss after a few seconds. Restarting on `message` means a fresh failure re-shows it;
        // unmounting (the parent clears `notice`) cancels the timer. No animation modifiers.
        .task(id: message) {
            try? await Task.sleep(for: .seconds(4))
            onDismiss()
        }
    }
}

#Preview {
    ThemedRoot(themeManager: ThemeManager(defaults: UserDefaults(suiteName: "NoticeBannerPreview")!)) {
        VStack(spacing: 0) {
            NoticeBanner(message: "Couldn't save your macro changes.") {
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
