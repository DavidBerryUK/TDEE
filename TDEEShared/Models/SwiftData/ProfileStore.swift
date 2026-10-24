import Observation
import Foundation

/// A lightweight, observable snapshot of a stored profile: enough for a list row and a switch target.
public struct ProfileSummary: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var isActive: Bool
    public var isMain: Bool

    public init(id: UUID, name: String, isActive: Bool, isMain: Bool) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.isMain = isMain
    }
}

/// In-session holder for the app's profiles: the list, the active profile id, and CRUD.
///
/// Mirrors `MacroSplitOptionsModelCollection`. The active profile is an *in-session* choice
/// (defaults to Main on launch) and is not persisted: relaunching returns to Main.
/// The Main profile (named "Main") and the last remaining profile can never be deleted.
@Observable
@MainActor
final class ProfileStore {

    /// The profiles, ordered Main first then alphabetically by name.
    private(set) var profiles: [ProfileSummary] = []

    /// The profile the app is currently showing. In-session only; relaunch returns to Main.
    private(set) var activeProfileId: UUID = UUID()

    private let repository: ProfileRepository?

    /// The currently active summary, if one is loaded.
    var activeProfile: ProfileSummary? {
        profiles.first { $0.id == activeProfileId }
    }

    /// The Main summary, if any.
    var mainProfile: ProfileSummary? {
        profiles.first { $0.isMain }
    }

    // MARK: - Init

    /// Default empty store (for previews / back-compat).
    init() {
        self.repository = nil
    }

    /// New store backed by a repository. The caller must await `load()` before using `profiles`.
    init(profileRepository: ProfileRepository) {
        self.repository = profileRepository
    }

    // MARK: - Loading

    /// Ensure a Main profile exists, then load the list. The in-session active profile
    /// is preserved across reloads — falling back to Main only when the current choice
    /// no longer exists — so `add()`/`rename()` don't bounce the selection back to Main.
    func load() async {
        guard let repository else { return }
        do {
            try await repository.ensureMainProfile()
            let all = try await repository.fetchAllProfiles()
            // Keep the current active choice when it still exists; otherwise fall back to
            // Main, then any remaining profile. A fresh store's default id never matches a
            // stored profile, so first launch / relaunch still open on Main.
            if !all.contains(where: { $0.id == activeProfileId }) {
                let mainId = all.first(where: { $0.name == ProfileRepository.mainProfileName })?.id
                activeProfileId = mainId ?? all.first?.id ?? activeProfileId
            }
            profiles = all.map {
                ProfileSummary(
                    id: $0.id,
                    name: $0.name,
                    isActive: $0.id == activeProfileId,
                    isMain: $0.name == ProfileRepository.mainProfileName
                )
            }
        } catch {
            print("Failed to load profiles: \(error)")
        }
    }

    // MARK: - Selection (in-session)

    /// Switch the active profile to `id` (used by the quick-switch and the list).
    /// Named `activate` because `switch` is a Swift keyword.
    func activate(to id: UUID) {
        guard profiles.contains(where: { $0.id == id }) else { return }
        activeProfileId = id
        for index in profiles.indices { profiles[index].isActive = (profiles[index].id == id) }
    }

    // MARK: - CRUD

    /// Create a new, named profile. Returns its id, or nil if the name is empty,
    /// blank, or would collide with an existing profile (including "Main").
    @discardableResult
    func add(name: String) async -> UUID? {
        guard let repository else { return nil }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !profiles.contains(where: { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame })
        else { return nil }
        do {
            let profile = try await repository.createProfile(name: trimmed)
            await load()
            return profile.id
        } catch {
            print("Failed to create profile: \(error)")
            return nil
        }
    }

    /// Rename a non-Main profile. Main cannot be renamed, and no profile may take the name "Main".
    func rename(id: UUID, to name: String) async {
        guard let repository else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != ProfileRepository.mainProfileName,
              let summary = profiles.first(where: { $0.id == id }),
              !summary.isMain,
              !profiles.contains(where: { $0.id != id && $0.name.caseInsensitiveCompare(trimmed) == .orderedSame })
        else { return }
        do {
            try await repository.renameProfile(id: id, to: trimmed)
            await load()
        } catch {
            print("Failed to rename profile: \(error)")
        }
    }

    /// Whether the profile with `id` may be deleted (not Main, not the last remaining).
    func canDelete(_ id: UUID) -> Bool {
        guard let summary = profiles.first(where: { $0.id == id }) else { return false }
        return !summary.isMain && profiles.count > 1
    }

    /// Delete a profile. Guarded (Main / last are refused). If the active profile is removed,
    /// the active selection falls back to Main, then any remaining profile.
    func delete(id: UUID) async {
        guard canDelete(id) else { return }
        do {
            try await repository?.deleteProfile(byId: id)
        } catch {
            print("Failed to delete profile: \(error)")
            return
        }
        profiles.removeAll { $0.id == id }
        if activeProfileId == id {
            activeProfileId = profiles.first(where: { $0.isMain })?.id ?? profiles[profiles.startIndex].id
            for index in profiles.indices { profiles[index].isActive = (profiles[index].id == activeProfileId) }
        }
    }
}
