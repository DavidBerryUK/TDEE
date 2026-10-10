//
//  ConfigLoader.swift
//  SimpleTest
//
//  Created by David Berry on 11 Oct 2026.
//

import Foundation

/// Loads configuration defaults based on the runtime environment.
/// Uses compiler directives to determine if running on simulator or device.
struct ConfigLoader {

    /// Loads profile defaults appropriate for the current environment.
    /// - Returns: ProfileDefaults configured for simulator or device based on `#if targetEnvironment(simulator)`
    static func loadProfileDefaults() -> ProfileDefaults {
        #if targetEnvironment(simulator)
        return ProfileDefaults.simulator()
        #else
        return ProfileDefaults.device()
        #endif
    }
}
