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
                // New (unmanaged) entities must be inserted; tracked ones are already in the context
                if profile.modelContext == nil {
                    context.insert(profile)
                }
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
            gender: Int16(defaults.gender.rawValue),
            age: defaults.age,
            height: defaults.height,
            weight: defaults.weight,
            bodyFatPercentage: defaults.bodyFatPercentage,
            activityLevel: defaults.activityLevel,
            id: ProfileRepository.activeProfileId,
            createdAt: Date(),
            updatedAt: Date()
        )
        context.insert(profile)  // New entity - safe to insert
        try context.save()
        return profile
    }

    /// Insert the preset, or copy its values onto the stored preset with the same id.
    private func upsertPreset(_ preset: MacroPreset) throws {
        let id = preset.id
        let existing = try context.fetch(FetchDescriptor<MacroPreset>(predicate: #Predicate { $0.id == id })).first
        guard let existing else {
            context.insert(preset)
            return
        }
        if existing === preset { return }
        existing.name = preset.name
        existing.primaryCalories = preset.primaryCalories
        existing.primaryCarbs = preset.primaryCarbs
        existing.primaryFat = preset.primaryFat
        existing.primaryProtein = preset.primaryProtein
        existing.ordinal = preset.ordinal
        existing.isCustom = preset.isCustom
        existing.updatedAt = Date()
    }

    /// Delete the preset with the given id, if stored.
    func deletePreset(id: UUID) async throws {
        let matches = try context.fetch(FetchDescriptor<MacroPreset>(predicate: #Predicate { $0.id == id }))
        matches.forEach { context.delete($0) }
        try context.save()
    }

    /// Save a preset (shared, no owner)
    func savePreset(_ preset: MacroPreset) async throws {
        let maxRetries = 3
        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                try upsertPreset(preset)
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
