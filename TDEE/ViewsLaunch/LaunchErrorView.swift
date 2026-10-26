//
//  LaunchErrorView.swift
//  TDEE
//
//  Created by David Berry on 25/10/2026.
//

import SwiftUI

/// The full-screen recovery screen shown when the on-disk store can't be opened at launch (PA-32).
///
/// Replaces the old `fatalError` trap: instead of crashing, the app offers two recoveries —
/// "Try Again" (`onRetry`, re-opens the existing store) and "Reset Stored Data" (`onReset`, wipes
/// and reopens a fresh store, confirmed by a destructive alert). The headline and explanation come
/// from `LaunchFailure`, so the same view serves a first failure and a repeated post-reset failure.
struct LaunchErrorView: View {
    let failure: LaunchFailure
    var onRetry: () -> Void
    var onReset: () -> Void

    @Environment(\.palette) private var palette
    @State private var confirmingReset = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(palette.primary)
                .accessibilityHidden(true)

            Text(failure.userMessage)
                .font(.title2)
                .bold()
                .foregroundStyle(palette.text)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text(failure.detail)
                .font(.subheadline)
                .foregroundStyle(palette.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 24)

            VStack(spacing: 10) {
                Button(action: onRetry) {
                    Text("Try Again")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    confirmingReset = true
                } label: {
                    Text("Reset Stored Data")
                }
                .buttonStyle(.bordered)

                Text("Resetting deletes your saved profiles and macros, and starts TDEE fresh.")
                    .font(.caption)
                    .foregroundStyle(palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.background)
        .accessibilityElement(children: .contain)
        // A destructive reset is confirmed before it deletes anything.
        .alert(
            "Reset stored data?",
            isPresented: $confirmingReset,
            actions: {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    onReset()
                }
            },
            message: {
                Text("This deletes all your saved profiles and macros. You'll need to re-enter your details.")
            })
    }
}

#Preview {
    ThemedRoot(themeManager: ThemeManager(defaults: UserDefaults(suiteName: "LaunchErrorPreview")!)) {
        LaunchErrorView(
            failure: .notAttempted,
            onRetry: {},
            onReset: {})
    }
}
