import SwiftData

@MainActor
struct SwiftDataContainer {
    static let shared = SwiftDataContainer()

    let container: ModelContainer
    let profileRepository: ProfileRepository

    init(isInMemory: Bool = false) {
        let config = ModelConfiguration(
            isStoredInMemoryOnly: isInMemory
        )
        // No iCloud container properties - local only for now

        do {
            container = try ModelContainer(for: Profile.self, MacroPreset.self, configurations: config)
            profileRepository = ProfileRepository(context: container.mainContext)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var modelContext: ModelContext {
        container.mainContext
    }
}