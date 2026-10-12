//
//  AppConfig.swift
//  SimpleTest
//
//  Created by David Berry on 11 Oct 2026.
//

import Foundation

/// Main configuration entry point for the application.
/// Provides access to environment-specific default values.
struct AppConfig: Sendable {
    static let shared = AppConfig()

    let profileDefaults: ProfileDefaults

    private init() {
        self.profileDefaults = ConfigLoader.loadProfileDefaults()
    }
}
