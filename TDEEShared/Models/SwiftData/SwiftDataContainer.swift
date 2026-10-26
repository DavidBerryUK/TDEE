import SwiftData
import Foundation
import os

@MainActor
struct SwiftDataContainer {

    /// Error-logging channel for a store that can't be opened (lost in a release build via `print`).
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DaveBerryUk.TDEE", category: "SwiftDataContainer")

    /// Crash-safe, process-wide container for previews and the preview-only `ProfileViewModel()`
    /// convenience init. Prefers the on-disk store outside tests and an in-memory store under test,
    /// and — so it can never trap a preview or a test — falls back to an in-memory store if the
    /// preferred one fails to open. The *running apps* don't rely on this: they open their own store
    /// with `makeStore(reset:)`, which surfaces a failure to a recovery screen instead of trapping.
    static let shared = SwiftDataContainer(
        isInMemory: ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    )

    let container: ModelContainer
    let profileRepository: ProfileRepository

    /// Designated initialiser: adopt an already-open container.
    init(container: ModelContainer) {
        self.container = container
        self.profileRepository = ProfileRepository(container: container)
    }

    /// Build a store. The on-disk path can fail (a corrupt or incompatible file, or no storage at
    /// all); that is logged and falls back to an in-memory store so this never traps the caller —
    /// which is a preview or a test, not a running app. `makeStore(reset:)` is the throwing entry
    /// the apps use when they'd rather recover than fall back.
    init(isInMemory: Bool = false) {
        // In-memory stores are keyed by name, so give each its own to keep containers isolated.
        let config = isInMemory
            ? ModelConfiguration(UUID().uuidString, isStoredInMemoryOnly: true)
            : ModelConfiguration()
        // No iCloud container properties - local only for now.
        do {
            self.container = try ModelContainer(for: Profile.self, MacroPreset.self, configurations: config)
            self.profileRepository = ProfileRepository(container: self.container)
        } catch {
            // An in-memory open needs no on-disk files, so it cannot fail in practice; a failure
            // here would be a SwiftData engine bug, not user data. Hence the `try!` last resort.
            Self.logger.error("SwiftData: the on-disk store could not be opened (\(error)); using an in-memory store")
            let fallback = ModelConfiguration(UUID().uuidString, isStoredInMemoryOnly: true)
            self.container = try! ModelContainer(for: Profile.self, MacroPreset.self, configurations: fallback)
            self.profileRepository = ProfileRepository(container: self.container)
        }
    }

    /// Open (or, when `reset` is true, wipe-then-open) the on-disk store for a running app.
    ///
    /// Unlike `init(isInMemory:)`, this does **not** fall back to in-memory: a failure is thrown so
    /// the caller (`LaunchStore`) can offer recovery instead of silently using a store that won't
    /// persist. `reset` is the recovery for a corrupt/incompatible store — the only path that can
    /// recover data the open can't read.
    static func makeStore(reset: Bool = false) throws -> SwiftDataContainer {
        if reset {
            SwiftDataStoreFile.removeAll()
        }
        let container = try ModelContainer(for: Profile.self, MacroPreset.self, configurations: ModelConfiguration())
        return SwiftDataContainer(container: container)
    }

    var modelContext: ModelContext {
        container.mainContext
    }
}
