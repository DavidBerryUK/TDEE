import Testing
import SwiftData
@testable import SimpleTest
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

    @Test("Saving the profile repeatedly keeps a single active profile")
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
        #expect(stored.first?.id == ProfileRepository.activeProfileId)
        #expect(stored.first?.age == 42)
    }

    @Test("Profile fields and selected macro round-trip")
    func profileRoundTrip() async throws {
        let container = makeContainer()
        let profile = ProfileViewModel(profileRepository: container.profileRepository)
        await profile.load()
        profile.age = 37
        profile.weight = 81.5
        profile.activityLevel = .active
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
        #expect(reloaded.activityLevel == .active)
        #expect(reloaded.bodyFatPercentageMethod == .manualEntry)
        #expect(reloaded.bodyFatPercentage == 18)
        #expect(reloaded.calorieAdjustmentMethod == .cut)
        #expect(reloaded.calorieAdjustment == 300)
        #expect(reloaded.selectedMacroId == FactoryMacroSplits.Id.ketogenic)
    }
}
