//
//  WatchLaunchErrorView.swift
//  TDEE Watch
//
//  Created by David Berry on 25/10/2026.
//

import SwiftUI

/// The full-screen recovery screen shown when the on-disk store can't be opened at launch (PA-32).
///
/// The watch is a compact, `List`-based surface, so the reset confirmation is a second screen
/// driven by `@State` (version-safe across watchOS) rather than a `.alert`. The text comes from
/// `LaunchFailure`, so the same view serves a first failure and a repeated post-reset failure.
struct WatchLaunchErrorView: View {
    let failure: LaunchFailure
    var onRetry: () -> Void
    var onReset: () -> Void

    @State private var confirmingReset = false

    var body: some View {
        if confirmingReset {
            confirmScreen
        } else {
            mainScreen
        }
    }

    private var mainScreen: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28))
                .foregroundStyle(WatchPalette.attention)
                .accessibilityHidden(true)

            Text("Can't open saved data")
                .font(.headline)

            Text("Try again, or reset the saved data to start fresh.")
                .font(.caption2)
                .foregroundStyle(WatchPalette.textSecondary)
                .multilineTextAlignment(.center)

            Spacer(minLength: 4)

            Button(action: onRetry) {
                Text("Try Again")
            }
            Button {
                confirmingReset = true
            } label: {
                Text("Reset data")
            }
            .tint(WatchPalette.attention)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var confirmScreen: some View {
        VStack(spacing: 8) {
            Text("Delete all saved data?")
                .font(.headline)

            Text("You'll need to re-enter your details.")
                .font(.caption2)
                .foregroundStyle(WatchPalette.textSecondary)
                .multilineTextAlignment(.center)

            Spacer(minLength: 4)

            HStack {
                Button {
                    confirmingReset = false
                } label: {
                    Text("Cancel")
                }
                Button {
                    onReset()
                } label: {
                    Text("Reset")
                }
                .tint(WatchPalette.attention)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WatchLaunchErrorView(failure: .notAttempted, onRetry: {}, onReset: {})
}
