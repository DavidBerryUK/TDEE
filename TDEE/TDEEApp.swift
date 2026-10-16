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

    var body: some Scene {
        WindowGroup {
            ThemedRoot(themeManager: themeManager) {
                ContentView()
            }
        }
    }
}