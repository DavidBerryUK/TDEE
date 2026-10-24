import Testing
import SwiftData
@testable import TDEE
import Foundation

/// Story 017: preset and profile persistence. Each test uses an in-memory store;
/// a new collection or view model over the same container simulates a relaunch.
@Suite("SwiftData Persistence Tests")
@MainActor
struct SwiftDataPersistenceTests {

    private func makeContainer() -> SwiftDataContainer {
        SwiftDataContainer(isInMemory: true)
    }

    private func makeCollection(_ container: SwiftDataContainer) async -> MacroSplitOptionsModelCollection {
        let collection = MacroSplitOptionsModelCollection(profileRepository: container.profileRepository)
        await collection.loadPresets()
        return collection
    }

    private func storedPresetCount(_ container: SwiftDataContainer) throws -> Int {
        try container.modelContext.fetchCount(FetchDescriptor<MacroPreset>())
    }

    // MARK: - Seeding

    @Test("Empty store is seeded with the factory presets")
    func seedsOnFirstLaunch() async throws {
        let container = makeContainer()
        let collection = await makeCollection(container)

        #expect(collection.items.count == FactoryMacroSplits.get().count)
        #expect(try storedPresetCount(container) == FactoryMacroSplits.get().count)
    }

    @Test("Non-empty store is not re-seeded")
    func doesNotReseed() async throws {
        let container = makeContainer()
        let first = await makeCollection(container)
        first.remove(first.items[0])
        await first.flush()

        let second = await makeCollection(container)
        #expect(second.items.count == FactoryMacroSplits.get().count - 1)
    }

    // MARK: - Update / add / delete

    @Test("Edit persists across relaunch with no duplicates")
    func editPersists() async throws {
        let container = makeContainer()
        let collection = await makeCollection(container)

        let edited = collection.items[0].clone()
        edited.name = "Edited"
        edited.protein = 50; edited.carbs = 30; edited.fats = 20
        collection.update(edited)
        await collection.flush()

        let relaunched = await makeCollection(container)
        let stored = try #require(relaunched.items.first { $0.id == edited.id })
        #expect(stored.name == "Edited")
        #expect(stored.protein == 50)
        #expect(relaunched.items.count == FactoryMacroSplits.get().count)
        #expect(try storedPresetCount(container) == FactoryMacroSplits.get().count)
    }

    @Test("Updating an unknown macro adds it as a custom preset")
    func addViaUpdate() async throws {
        let container = makeContainer()
        let collection = await makeCollection(container)

        let new = MacroSplitOptionModel(name: "Mine", protein: 40, carbs: 30, fats: 30)
        collection.update(new)
        await collection.flush()

        #expect(collection.items.contains { $0.id == new.id && $0.isCustom })

        let relaunched = await makeCollection(container)
        let stored = try #require(relaunched.items.first { $0.id == new.id })
        #expect(stored.name == "Mine")
        #expect(stored.isCustom)
        #expect(relaunched.items.count == FactoryMacroSplits.get().count + 1)
    }

    @Test("Delete removes the preset from the store")
    func deletePersists() async throws {
        let container = makeContainer()
        let collection = await makeCollection(container)
        let victim = collection.items[2]

        collection.remove(victim)
        await collection.flush()

        let relaunched = await makeCollection(container)
        #expect(!relaunched.items.contains { $0.id == victim.id })
    }

    @Test("The last remaining macro cannot be deleted")
    func lastMacroProtected() async throws {
        let container = makeContainer()
        let collection = await makeCollection(container)
        for item in collection.items { collection.remove(item) }
        await collection.flush()

        #expect(collection.items.count == 1)
        #expect(try storedPresetCount(container) == 1)
    }

    @Test("Reorder persists ordinals")
    func reorderPersists() async throws {
        let container = makeContainer()
        let collection = await makeCollection(container)
        let movedId = collection.sortedItems[0].id

        collection.move(from: IndexSet(integer: 0), to: collection.items.count)
        await collection.flush()

        let relaunched = await makeCollection(container)
        #expect(relaunched.sortedItems.last?.id == movedId)
    }

    // MARK: - Reset

    @Test("Reset restores exactly the factory presets")
    func resetToDefaults() async throws {
        let container = makeContainer()
        let collection = await makeCollection(container)
        collection.update(MacroSplitOptionModel(name: "Mine", protein: 40, carbs: 30, fats: 30))
        let edited = collection.items.first { !$0.isCustom }!.clone()
        edited.name = "Changed"
        collection.update(edited)
        collection.remove(collection.items.last!)
        await collection.flush()

        await collection.resetToDefaults()

        let factoryIds = Set(FactoryMacroSplits.get().map(\.id))
        #expect(Set(collection.items.map(\.id)) == factoryIds)
        #expect(try storedPresetCount(container) == factoryIds.count)

        let relaunched = await makeCollection(container)
        #expect(Set(relaunched.items.map(\.id)) == factoryIds)
        #expect(!relaunched.items.contains { $0.name == "Changed" })
    }

    // MARK: - Profile

    @Test("Saving the profile repeatedly keeps a single Main profile")
    func singleProfile() async throws {
        let container = makeContainer()
        let profile = ProfileViewModel(profileRepository: container.profileRepository)
        await profile.load()
        profile.age = 41
        await profile.saveToSwiftData()
        profile.age = 42
        await profile.saveToSwiftData()

        let stored = try container.modelContext.fetch(FetchDescriptor<Profile>())
        #expect(stored.count == 1)
        #expect(stored.first?.name == ProfileRepository.mainProfileName)
        #expect(stored.first?.age == 42)
    }

    @Test("Profile fields and selected macro round-trip")
    func profileRoundTrip() async throws {
        let container = makeContainer()
        let profile = ProfileViewModel(profileRepository: container.profileRepository)
        await profile.load()
        profile.age = 37
        profile.weight = 81.5
        profile.activityLevel = .heavyExercise
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 18
        profile.calorieAdjustmentMethod = .cut
        profile.calorieAdjustment = 300
        profile.selectedMacroId = FactoryMacroSplits.Id.ketogenic
        await profile.saveToSwiftData()

        let reloaded = ProfileViewModel(profileRepository: container.profileRepository)
        await reloaded.load()
        #expect(reloaded.age == 37)
        #expect(reloaded.weight == 81.5)
        #expect(reloaded.activityLevel == .heavyExercise)
        #expect(reloaded.bodyFatPercentageMethod == .manualEntry)
        #expect(reloaded.bodyFatPercentage == 18)
        #expect(reloaded.calorieAdjustmentMethod == .cut)
        #expect(reloaded.calorieAdjustment == 300)
        #expect(reloaded.selectedMacroId == FactoryMacroSplits.Id.ketogenic)
    }

    // MARK: - Multiple profiles

    private func makeStore(_ container: SwiftDataContainer) async -> ProfileStore {
        let store = ProfileStore(profileRepository: container.profileRepository)
        await store.load()
        return store
    }

    private func storedProfileCount(_ container: SwiftDataContainer) throws -> Int {
        try container.modelContext.fetchCount(FetchDescriptor<Profile>())
    }

    @Test("The app opens to a single Main profile, identified by name")
    func mainProfileByName() async throws {
        let container = makeContainer()
        let store = await makeStore(container)

        #expect(store.profiles.count == 1)
        #expect(store.profiles.first?.isMain == true)
        #expect(store.activeProfile?.name == ProfileRepository.mainProfileName)
        #expect(try storedProfileCount(container) == 1)
    }

    @Test("Creating a named profile adds it to the list and persists it")
    func createProfilePersists() async throws {
        let container = makeContainer()
        let store = await makeStore(container)

        let id = try #require(await store.add(name: "Partner"))
        #expect(store.profiles.count == 2)
        #expect(store.profiles.contains { $0.id == id && $0.name == "Partner" })
        #expect(try storedProfileCount(container) == 2)

        // Relaunch: a fresh store over the same container sees both.
        let relaunched = await makeStore(container)
        #expect(relaunched.profiles.count == 2)
        #expect(relaunched.profiles.contains { $0.name == "Partner" })
        #expect(try storedProfileCount(container) == 2)
    }

    @Test("The Main profile cannot be deleted")
    func mainProfileProtected() async throws {
        let container = makeContainer()
        let store = await makeStore(container)
        let mainId = try #require(store.mainProfile?.id)

        await store.delete(id: mainId)
        #expect(store.profiles.count == 1)
        #expect(store.profiles.first?.isMain == true)
        #expect(try storedProfileCount(container) == 1)
    }

    @Test("The last remaining profile cannot be deleted")
    func lastProfileProtected() async throws {
        let container = makeContainer()
        let store = await makeStore(container)
        let only = try #require(store.profiles.first?.id)

        await store.delete(id: only)
        #expect(store.profiles.count == 1)
        #expect(try storedProfileCount(container) == 1)
    }

    @Test("A non-Main profile can be deleted")
    func nonMainProfileDeleted() async throws {
        let container = makeContainer()
        let store = await makeStore(container)
        let guestId = try #require(await store.add(name: "Guest"))

        await store.delete(id: guestId)
        #expect(!store.profiles.contains { $0.id == guestId })
        #expect(store.profiles.count == 1)
        #expect(try storedProfileCount(container) == 1)
    }

    @Test("A profile's name round-trips through SwiftData")
    func nameRoundTrip() async throws {
        let container = makeContainer()
        let store = await makeStore(container)
        let id = try #require(await store.add(name: "Me"))

        let relaunched = await makeStore(container)
        let reloaded = try #require(relaunched.profiles.first { $0.id == id })
        #expect(reloaded.name == "Me")
    }

    @Test("Renaming a profile persists")
    func renamePersists() async throws {
        let container = makeContainer()
        let store = await makeStore(container)
        let id = try #require(await store.add(name: "Temp"))

        await store.rename(id: id, to: "Renamed")
        #expect(store.profiles.contains { $0.id == id && $0.name == "Renamed" })

        let relaunched = await makeStore(container)
        #expect(relaunched.profiles.contains { $0.name == "Renamed" })
    }

    @Test("Relaunching opens Main, not the last-used profile")
    func relaunchOpensMain() async throws {
        let container = makeContainer()
        let store = await makeStore(container)
        let partnerId = try #require(await store.add(name: "Partner"))
        store.activate(to: partnerId)
        #expect(store.activeProfile?.name == "Partner")

        // A fresh store (simulating relaunch) defaults back to Main.
        let relaunched = await makeStore(container)
        #expect(relaunched.activeProfile?.name == ProfileRepository.mainProfileName)
    }
}
