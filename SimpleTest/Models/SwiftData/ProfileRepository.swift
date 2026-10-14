import SwiftData
import Foundation

/// ProfileRepository manages all profile and preset persistence.
/// Uses @MainActor because ModelContext is not thread-safe.
@MainActor class ProfileRepository {
    private let context: ModelContext

    static let activeProfileId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!

    init(context: ModelContext) {
        self.context = context
    }

    func fetchActiveProfile() async throws -> Profile? {
        // Simple fetch and filter approach to avoid predicate syntax issues
        let request = FetchDescriptor<Profile>()
        let profiles = try context.fetch(request)
        for profile in profiles {
            if profile.id == ProfileRepository.activeProfileId {
                return profile
            }
        }
        return nil
    }

    /// Fetch all shared presets (presets are a shared catalog, no owner filter needed)
    func fetchPresets() async throws -> [MacroPreset] {
        let request = FetchDescriptor<MacroPreset>()
        return try context.fetch(request)
    }

    /// Save profile with retry logic (3 attempts)
    /// Distinguishes create (new entity) from update (existing entity)
    func save(_ profile: Profile) async throws {
        let maxRetries = 3
        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                // For updates, the entity is already tracked by the context
                try context.save()
                return  // Success
            } catch {
                lastError = error
                if attempt < maxRetries {
                    // Wait before retry (linear backoff: 100ms, 200ms)
                    try? await Task.sleep(nanoseconds: UInt64(100_000_000 * UInt64(attempt)))
                }
            }
        }

        // All retries failed - surface error to caller
        throw lastError ?? SwiftDataError.failedToSave
    }

    func createDefaultProfile() async throws -> Profile {
        let defaults = SeedData.profileDefaults()
        let profile = Profile(
            id: ProfileRepository.activeProfileId,
            gender: Int16(defaults.gender.rawValue),
            age: Int16(defaults.age),
            height: defaults.height,
            weight: defaults.weight,
            activityLevel: Int16(defaults.activityLevel.rawValue),
            bodyFatPercentage: defaults.bodyFatPercentage,
            bodyFatMethod: Int16(defaults.bodyFatPercentageMethod.rawValue),
            name: nil,
            seedVersion: SeedData.version,
            createdAt: Date(),
            updatedAt: Date()
        )
        context.insert(profile)  // New entity - safe to insert
        try context.save()
        return profile
    }

    /// Save a preset (shared, no owner)
    func savePreset(_ preset: MacroPreset) async throws {
        let maxRetries = 3
        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                context.insert(preset) // Insert new entity
                try context.save()
                return  // Success
            } catch {
                lastError = error
                if attempt < maxRetries {
                    // Wait before retry (linear backoff: 100ms, 200ms)
                    try? await Task.sleep(nanoseconds: UInt64(100_000_000 * UInt64(attempt)))
                }
            }
        }

        // All retries failed - surface error to caller
        throw lastError ?? SwiftDataError.failedToSave
    }
}

// Custom error for SwiftData operations
enum SwiftDataError: Error {
    case failedToSave
}
