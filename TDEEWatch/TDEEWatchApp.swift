//
//  TDEEWatchApp.swift
//  TDEE Watch
//

import SwiftUI

@main
struct TDEEWatchApp: App {

    // Created once here, not in a view init: the App body can re-run, and a view init would
    // build (and load, and save) a new ProfileViewModel each time.
    @State private var profile: ProfileViewModel
    @State private var macroCollection: MacroSplitOptionsModelCollection

    init() {
        let repository = SwiftDataContainer.shared.profileRepository
        let profile = ProfileViewModel(profileRepository: repository)
        let macroCollection = MacroSplitOptionsModelCollection(profileRepository: repository)
        profile.macroCollection = macroCollection
        self._profile = State(initialValue: profile)
        self._macroCollection = State(initialValue: macroCollection)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WatchMainView(profile: profile)
            }
                .task { await macroCollection.loadPresets() }
        }
    }
}
