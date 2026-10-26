//
//  TDEEWatchApp.swift
//  TDEE Watch
//
//  Created by David Berry on 31/03/2026.
//

import SwiftUI

@main
struct TDEEWatchApp: App {

    // Opens the store up front; the first body render already knows the outcome, so the app never
    // starts on a half-opened store. A failure routes to the recovery screen instead of a trap.
    @State private var launch = LaunchStore()

    var body: some Scene {
        WindowGroup {
            switch launch.outcome {
            case .ready(let repository):
                WatchLaunchView(repository: repository)
            case .failed(let failure):
                WatchLaunchErrorView(
                    failure: failure,
                    onRetry: { launch.retry() },
                    onReset: { launch.reset() })
            }
        }
    }
}

/// Builds the watch models once the store has opened, then runs them.
///
/// The models can't be `@State` in `TDEEWatchApp`: a `@State` default must always run, but the store
/// open can fail. `LaunchStore` decides readiness and this view is built only on the `.ready` branch.
private struct WatchLaunchView: View {
    @State private var profile: ProfileViewModel
    @State private var macroCollection: MacroSplitOptionsModelCollection

    init(repository: ProfileRepository) {
        let profile = ProfileViewModel(profileRepository: repository)
        let macroCollection = MacroSplitOptionsModelCollection(profileRepository: repository)
        profile.macroCollection = macroCollection
        self._profile = State(initialValue: profile)
        self._macroCollection = State(initialValue: macroCollection)
    }

    var body: some View {
        NavigationStack {
            WatchMainView(profile: profile, macroCollection: macroCollection)
        }
        .task { await macroCollection.loadPresets() }
    }
}
