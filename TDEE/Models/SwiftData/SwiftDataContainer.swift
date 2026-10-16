import SwiftData
import Foundation

@MainActor
struct SwiftDataContainer {
    /// Unit tests run against an in-memory store so they never touch (or depend on) on-disk data.
    static let shared = SwiftDataContainer(
        isInMemory: ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    )

    let container: ModelContainer
    let profileRepository: ProfileRepository

    init(isInMemory: Bool = false) {
        // In-memory stores are keyed by name, so give each its own to keep containers isolated
        let config = isInMemory
            ? ModelConfiguration(UUID().uuidString, isStoredInMemoryOnly: true)
            : ModelConfiguration()
        // No iCloud container properties - local only for now

        do {
            container = try ModelContainer(for: Profile.self, MacroPreset.self, configurations: config)
            profileRepository = ProfileRepository(container: container)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var modelContext: ModelContext {
        container.mainContext
    }
}