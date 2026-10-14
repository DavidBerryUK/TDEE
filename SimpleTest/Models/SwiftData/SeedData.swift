import Foundation

/// Seed data for initial app setup - reuses existing defaults
enum SeedData {
    static let version: Int16 = 1

    /// Returns profile defaults matching current environment
    static func profileDefaults() -> ProfileDefaults {
        #if targetEnvironment(simulator)
        return ProfileDefaults.simulator()
        #else
        return ProfileDefaults.device()
        #endif
    }

    /// Returns macro presets from existing factory
    static func macroPresets() -> [MacroSplitOptionModel] {
        return FactoryMacroSplits.get()
    }
}