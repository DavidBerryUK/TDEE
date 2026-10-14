//
//  SimpleTestApp.swift
//  SimpleTest
//
//  Created by David Berry on 31/03/2026.
//

import SwiftUI
import SwiftData

@main
struct SimpleTestApp: App {

    // Initialize SwiftData container
    private let swiftDataContainer = SwiftDataContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}