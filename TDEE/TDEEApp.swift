//
//  TDEEApp.swift
//  TDEE
//
//  Created by David Berry on 31/03/2026.
//

import SwiftUI
import SwiftData

@main
struct TDEEApp: App {

    // Initialize SwiftData container
    private let swiftDataContainer = SwiftDataContainer.shared

    @State private var themeManager = ThemeManager()
    @State private var inputStyleManager = InputStyleManager()

    // Created once here: the App body re-runs, and ContentView.init with it
    @State private var profile = ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository)
    @State private var macroCollection = MacroSplitOptionsModelCollection(profileRepository: SwiftDataContainer.shared.profileRepository)
    @State private var profileStore = ProfileStore(profileRepository: SwiftDataContainer.shared.profileRepository)

    var body: some Scene {
        WindowGroup {
            ThemedRoot(themeManager: themeManager, inputStyleManager: inputStyleManager) {
                ContentView(profile: profile, macroCollection: macroCollection, profileStore: profileStore)
            }
        }
    }
}