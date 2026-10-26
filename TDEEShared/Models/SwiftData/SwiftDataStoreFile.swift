import Foundation

/// Locates and removes the on-disk SwiftData store.
///
/// The "Reset stored data" recovery action (see `LaunchStore.reset`) wipes a corrupt or
/// incompatible store so a fresh one can be opened. This is the only thing that touches the
/// store's files directly; `SwiftDataContainer` itself never does.
enum SwiftDataStoreFile {

    /// The on-disk store's file name. A bare `ModelConfiguration()` (no custom name) stores
    /// SwiftData at `default.store` in the app's Application Support directory.
    static let storeName = "default.store"

    /// Best-effort removal of the on-disk store. Never throws: a missing store (first launch, or
    /// the store lives elsewhere) is not an error and is simply ignored. `Void` on purpose — a wipe
    /// we can't perform just means the open that follows fails, and that failure is surfaced by the
    /// caller's `catch`, so there is nothing extra to report here.
    static func removeAll() {
        guard let support = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true) else { return }
        // `removeItem` handles both a `.store` file and a `.store` directory, and a non-existent
        // path is swallowed by `try?`.
        let storeURL = support.appendingPathComponent(storeName)
        try? FileManager.default.removeItem(at: storeURL)
    }
}
