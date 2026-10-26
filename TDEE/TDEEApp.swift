//
//  TDEEApp.swift
//  TDEE
//
//  Created by David Berry on 31/03/2026.
//

import SwiftUI

@main
struct TDEEApp: App {

    @State private var themeManager = ThemeManager()
    @State private var inputStyleManager = InputStyleManager()

    // Opens the store up front; the first body render already knows the outcome, so the app never
    // starts on a half-opened store. A failure routes to the recovery screen instead of a trap.
    @State private var launch = LaunchStore()

    var body: some Scene {
        WindowGroup {
            ThemedRoot(themeManager: themeManager, inputStyleManager: inputStyleManager) {
                switch launch.outcome {
                case .ready(let repository):
                    PhoneLaunchView(repository: repository)
                case .failed(let failure):
                    LaunchErrorView(
                        failure: failure,
                        onRetry: { launch.retry() },
                        onReset: { launch.reset() })
                }
            }
        }
    }
}

/// Builds the three app models only once the store has opened, then hands them to `ContentView`.
///
/// The models can't be `@State` in `TDEEApp`: a `@State` default must always run, but the store
/// open can fail. `LaunchStore` decides readiness and this view is built only on the `.ready`
/// branch, so the models are created from a live repository exactly once (not on every body re-run).
private struct PhoneLaunchView: View {
    @State private var profile: ProfileViewModel
    @State private var macroCollection: MacroSplitOptionsModelCollection
    @State private var profileStore: ProfileStore

    init(repository: ProfileRepository) {
        _profile = State(initialValue: ProfileViewModel(profileRepository: repository))
        _macroCollection = State(initialValue: MacroSplitOptionsModelCollection(profileRepository: repository))
        _profileStore = State(initialValue: ProfileStore(profileRepository: repository))
    }

    var body: some View {
        ContentView(profile: profile, macroCollection: macroCollection, profileStore: profileStore)
    }
}
