import SwiftData
import Foundation

/// ProfileRepository manages all profile and preset persistence.
/// Uses @MainActor because ModelContext is not thread-safe.
@MainActor class ProfileRepository {
    /// Keeps the container alive for as long as the repository: a ModelContext traps if its container is gone.
    private let container: ModelContainer
    private let context: ModelContext

    /// The name that identifies the Main (quick daily default) profile.
    nonisolated static let mainProfileName = "Main"

    init(container: ModelContainer) {
        self.container = container
        self.context = container.mainContext
    }

    /// Fetch the Main profile (the one named "Main"), if any.
    /// Simple fetch-and-filter to avoid string-predicate syntax issues (matches the old fetchActiveProfile style).
    func fetchMainProfile() async throws -> Profile? {
        let request = FetchDescriptor<Profile>()
        let profiles = try context.fetch(request)
        return profiles.first { $0.name == Self.mainProfileName }
    }

    /// Fetch every stored profile, ordered Main first then alphabetically by name.
    func fetchAllProfiles() async throws -> [Profile] {
        let all = try context.fetch(FetchDescriptor<Profile>())
        return all.sorted { lhs, rhs in
            let lhsMain = lhs.name == Self.mainProfileName
            let rhsMain = rhs.name == Self.mainProfileName
            if lhsMain != rhsMain { return lhsMain }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    /// Fetch a single profile by its id, if any.
    func fetchProfile(byId id: UUID) async throws -> Profile? {
        let request = FetchDescriptor<Profile>(predicate: #Predicate { $0.id == id })
        return try context.fetch(request).first
    }

    /// Fetch all shared presets (presets are a shared catalog, no owner filter needed)
    func fetchPresets() async throws -> [MacroPreset] {
        let request = FetchDescriptor<MacroPreset>(sortBy: [SortDescriptor(\.ordinal)])
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

    /// Create a new, named profile from the current environment's defaults.
    func createProfile(name: String) async throws -> Profile {
        let defaults = SeedData.profileDefaults()
        let profile = Profile(
            name: name,
            gender: Int16(defaults.gender.rawValue),
            age: defaults.age,
            height: defaults.height,
            weight: defaults.weight,
            bodyFatPercentage: defaults.bodyFatPercentage,
            activityLevel: defaults.activityLevel,
            selectedMacroId: FactoryMacroSplits.Id.balanced,
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        )
        context.insert(profile)  // New entity - safe to insert
        try context.save()
        return profile
    }

    /// Ensure a Main profile exists (first launch / empty store). Creates one if missing.
    @discardableResult
    func ensureMainProfile() async throws -> Profile {
        if let main = try await fetchMainProfile() { return main }
        return try await createProfile(name: Self.mainProfileName)
    }

    /// Rename the profile with the given id.
    func renameProfile(id: UUID, to name: String) async throws {
        let matches = try context.fetch(FetchDescriptor<Profile>(predicate: #Predicate { $0.id == id }))
        for profile in matches {
            profile.name = name
            profile.updatedAt = Date()
        }
        try context.save()
    }

    /// Delete the profile with the given id.
    /// Guarded: the Main profile and the last remaining profile cannot be deleted.
    func deleteProfile(byId id: UUID) async throws {
        let all = try await fetchAllProfiles()
        guard all.count > 1 else { throw SwiftDataError.cannotDeleteLastProfile }
        guard let target = all.first(where: { $0.id == id }), target.name != Self.mainProfileName
        else { throw SwiftDataError.cannotDeleteMainProfile }

        let matches = try context.fetch(FetchDescriptor<Profile>(predicate: #Predicate { $0.id == id }))
        matches.forEach { context.delete($0) }
        try context.save()
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
        existing.protein = preset.protein
        existing.carbs = preset.carbs
        existing.fats = preset.fats
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

    /// Insert the factory presets when the store holds no presets. Returns true if seeded.
    @discardableResult
    func seedPresetsIfEmpty() async throws -> Bool {
        guard try context.fetchCount(FetchDescriptor<MacroPreset>()) == 0 else { return false }
        for model in SeedData.macroPresets() {
            context.insert(MacroPresetMapper.mapToEntity(model))
        }
        try context.save()
        return true
    }

    /// Replace every stored preset with the factory presets.
    func resetPresetsToDefaults() async throws {
        try context.fetch(FetchDescriptor<MacroPreset>()).forEach { context.delete($0) }
        for model in SeedData.macroPresets() {
            context.insert(MacroPresetMapper.mapToEntity(model))
        }
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
    case cannotDeleteMainProfile
    case cannotDeleteLastProfile
}
