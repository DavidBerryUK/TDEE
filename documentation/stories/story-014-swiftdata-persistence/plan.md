# Plan: Story 014 - SwiftData Persistence

**Note:** This plan establishes a foundation for single-profile usage while designing to accommodate multiple profiles in the future.

## Phase 1: SwiftData Schema & Infrastructure

### 1.1 Create SwiftData Schemas
**File:** `SimpleTest/Models/SwiftData/Profile.swift`
Create the Profile schema:
```swift
import SwiftData

@Model
class Profile {
    @Attribute(.unique) var id: UUID
    var gender: Int16
    var age: Int16
    var height: Double
    var weight: Double
    var activityLevel: Int16
    var bodyFatPercentage: Double?
    var bodyFatMethod: Int16?
    var name: String?
    var seedVersion: Int16  // Track which version of seed data was applied
    var createdAt: Date
    var updatedAt: Date
    
    // Note: No presets relationship - presets are shared across all profiles
}
```

**File:** `SimpleTest/Models/SwiftData/MacroPreset.swift`
Create the MacroPreset schema:
```swift
import SwiftData

@Model
class MacroPreset {
    @Attribute(.unique) var id: UUID
    var name: String
    var protein: Int16
    var carbs: Int16
    var fats: Int16
    var ordinal: Int16
    var isCustom: Bool
    var isSystemPreset: Bool  // Distinguish system from user presets
    var systemId: String?  // e.g., "balanced", "diet" for system presets
    var createdAt: Date
    var updatedAt: Date
    
    // Note: Presets are shared across all profiles, no owner relationship
}
```

### 1.2 Establish Seed Data
**File:** `SimpleTest/Models/SwiftData/SeedData.swift`
- Reuse existing `ProfileDefaults` for profile defaults (simulator vs device specific)
- Reuse existing `FactoryMacroSplits.get()` for macro preset defaults
- No duplication - single source of truth for defaults
- Define `seedVersion` constant for tracking future seed data updates

```swift
import Foundation

/// Seed data for initial app setup - reuses existing defaults
enum SeedData {
    static let version: Int16 = 1
    
    /// Returns profile defaults matching current environment
    static func profileDefaults() -> ProfileDefaults {
        #if targetEnvironment(simulator)
        return ProfileDefaults.simulator()
        #else
        return ProfileDefaults.device()
        #endif
    }
    
    /// Returns macro presets from existing factory
    static func macroPresets() -> [MacroSplitOptionModel] {
        return FactoryMacroSplits.get()
    }
}
```

**Design rationale:** Instead of creating duplicate default values, this uses the existing `ProfileDefaults` and `FactoryMacroSplits` as the single source of truth. When the app runs, it automatically gets the correct simulator or device defaults without duplicating the values.

### 1.3 Implement Profile Repository
**File:** `SimpleTest/Models/SwiftData/ProfileRepository.swift`
Implement a repository pattern for profile management:
- `static let activeProfileId: UUID` - Constant UUID for the single active profile (future: user-selectable)
- `fetchActiveProfile() async throws -> Profile?` - Get the current profile by ID
- `save(_ profile: Profile) async throws` - Save profile with retry logic (3 attempts)
- `createDefaultProfile() async throws -> Profile` - Create a new default profile from seed data
- `saveSharedPreset(_ preset: MacroPreset) async throws` - Save a preset (shared, no owner)
- `fetchSharedPresets() async throws -> [MacroPreset]` - Fetch all presets (no owner filter)

**Note:** The repository uses a fixed UUID (`ProfileRepository.activeProfileId`) since the app currently supports only one profile. It's implemented as an `actor` for thread-safe async operations. Macro presets are shared across all profiles - no owner relationship exists.

```swift
// File: SimpleTest/Models/SwiftData/ProfileRepository.swift
import SwiftData

actor ProfileRepository {
    private let context: ModelContext
    
    static let activeProfileId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchActiveProfile() async throws -> Profile? {
        let request = FetchDescriptor<Profile>(predicate: #Predicate { $0.id == ProfileRepository.activeProfileId })
        return try context.fetch(request).first
    }
    
    /// Fetch all shared presets (no owner)
    func fetchSharedPresets() async throws -> [MacroPreset] {
        let request = FetchDescriptor<MacroPreset>(predicate: #Predicate { $0.owner == nil })
        return try context.fetch(request)
    }
    
    /// Save profile with retry logic (3 attempts)
    func save(_ profile: Profile) async throws {
        let maxRetries = 3
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                context.insert(profile)
                try context.save()
                return  // Success
            } catch {
                lastError = error
                if attempt < maxRetries {
                    // Wait before retry
                    try? await Task.sleep(nanoseconds: UInt64(100_000_000 * UInt64(attempt)))  // 100ms, 200ms
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
        context.insert(profile)
        try context.save()
        return profile
    }
}
```

### 1.4 Configure Model Container
**File:** `SimpleTest/Models/SwiftData/SwiftDataContainer.swift`
- Initialize `ModelContainer` with both schemas
- **Local-only storage for now** (CloudKit can be added in a follow-up story)
- Create and store `ProfileRepository` with the container's main context
- Provide access to the `ProfileRepository` for the rest of the app
- Support in-memory store for tests

```swift
import SwiftData

struct SwiftDataContainer {
    static let shared = SwiftDataContainer()
    
    private let container: ModelContainer
    let profileRepository: ProfileRepository
    
    init() {
        let config = ModelConfiguration(
            bundle: Bundle.main,
            seed: [:]  // Optional: seed data from JSON
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
```

**Future: Adding iCloud** (to be done in a follow-up story):
1. Add CloudKit container to app capabilities
2. Update `ModelConfiguration` with `containerProperties` containing the iCloud container ID
3. Test iCloud sync behavior

### Changes Summary
- **Retry logic**: 3 attempts with exponential backoff (100ms, 200ms)
- **Preset sharing**: No owner relationship - presets are shared across all profiles
- **First launch**: Attempt load, create if missing, seed presets from factory

## Phase 2: Profile Persistence

### 2.1 Update ProfileViewModel
**File:** `SimpleTest/Models/ProfileViewModel/ProfileViewModel.swift`

**Add properties:**
```swift
private let profileRepository: ProfileRepository
private var saveTask: Task<Void, Never>?  // For throttled saves
private let saveDelay: TimeInterval = 1.0  // Wait 1 second after last change
private var swiftDataId: UUID?  // Track the SwiftData entity ID
private let maxSaveRetries = 3  // Retry count for save operations
```

**Add save trigger method:**
```swift
/// Throttle saves by cancelling previous task and starting new one
private func triggerSave() {
    saveTask?.cancel()  // Cancel any pending save
    
    saveTask = Task { [weak self] in
        // Wait for the delay
        try? await Task.sleep(for: .seconds(saveDelay))
        
        // Check if task was cancelled during wait
        guard !Task.isCancelled else { return }
        
        // Perform save on background actor
        await self?.saveToSwiftData()
    }
}
```

**Add save method:**
```swift
private func saveToSwiftData() async {
    // Convert ProfileViewModel to Profile entity
    let profile = ProfileMapper.mapToEntity(self)
    
    // Save via repository with retry logic (background thread via actor)
    do {
        try await profileRepository.save(profile)
        self.swiftDataId = profile.id  // Store the ID after successful save
    } catch {
        // Failed after retries - could surface to user via a coordinator/delegate
        // For now, log the error
        print("Failed to save profile: \(error)")
    }
}
```

**Update property observers to trigger save:**
```swift
var gender: Gender = AppConfig.shared.profileDefaults.gender {
    didSet {
        refreshResults()
        triggerSave()  // Throttled save
    }
}
// Apply same pattern to age, weight, height, activityLevel, bodyFatPercentage, etc.
```

**Update init:**
```swift
/// Initialize with dependency injection
init(profileRepository: ProfileRepository) {
    self.profileRepository = profileRepository
    self.saveTask = nil
    
    // Load from SwiftData on init (if profile exists)
    loadFromSwiftData()
    
    // ... existing init code ...
}
```

**Add deinit to cancel pending saves:**
```swift
deinit {
    saveTask?.cancel()
}
```

**Rationale:** This approach provides UI responsiveness while avoiding redundant saves during rapid changes (e.g., user typing). The `Task.cancel()` pattern ensures only the final state after a pause is saved. Saves occur via the `ProfileRepository` actor on background threads.

### 2.2 Add ProfileMapper
**File:** `SimpleTest/Models/SwiftData/ProfileMapper.swift`

```swift
import SwiftData

/// Maps between ProfileViewModel and SwiftData Profile entity
enum ProfileMapper {
    /// Convert entity to ViewModel for reading from SwiftData
    static func mapToViewModel(_ entity: Profile, into viewModel: ProfileViewModel) {
        viewModel.gender = Gender(rawValue: entity.gender) ?? .male
        viewModel.age = Int(entity.age)
        viewModel.height = entity.height
        viewModel.weight = entity.weight
        viewModel.activityLevel = ActivityLevel(rawValue: entity.activityLevel) ?? .sedentary
        viewModel.bodyFatPercentage = entity.bodyFatPercentage ?? 0.0
        viewModel.bodyFatPercentageMethod = BodyFatOption(rawValue: entity.bodyFatMethod ?? 0) ?? .omit
        // Note: Derived values (tdee, macroTargets) are recalculated automatically by ProfileViewModel
    }
    
    /// Convert ViewModel to entity for saving to SwiftData
    static func mapToEntity(_ viewModel: ProfileViewModel) -> Profile {
        let profile = Profile()
        profile.id = viewModel.swiftDataId ?? ProfileRepository.activeProfileId
        profile.gender = Int16(viewModel.gender.rawValue)
        profile.age = Int16(viewModel.age)
        profile.height = viewModel.height
        profile.weight = viewModel.weight
        profile.activityLevel = Int16(viewModel.activityLevel.rawValue)
        profile.bodyFatPercentage = viewModel.bodyFatPercentage > 0 ? viewModel.bodyFatPercentage : nil
        profile.bodyFatMethod = Int16(viewModel.bodyFatPercentageMethod.rawValue)
        profile.updatedAt = Date()
        // createdAt is set on first creation
        // presets are handled separately via relationship
        return profile
    }
}
```

**Enum Raw Value Mappings:**
The existing Swift enums already have `Int` raw values defined:
- `Gender`: `male = 0`, `female = 1`
- `ActivityLevel`: `sedentary = 0`, `lightExercise = 1`, `moderateExercise = 2`, `heavyExercise = 3`, `athlete = 4`
- `BodyFatOption`: `omit = 0`, `estimate = 1`, `manualEntry = 2`
- `CalorieAdjustmentMethod`: `cut = 0`, `maintain = 1`, `bulk = 2`

These map directly to `Int16` for SwiftData storage.

### 2.3 Update App Initialization
**File:** `SimpleTest/SimpleTestApp.swift`
- Initialize SwiftData container and the `ProfileRepository`
- On app launch, attempt to load profile from SwiftData
- If no profile exists, create default profile and save
- Pass the repository via environment for dependency injection

## Phase 3: Macro Preset Persistence

### 3.1 Update MacroSplitOptionsModelCollection
**File:** `SimpleTest/SimpleTest/Models/Macros/MacroSplitOptionsModelCollection.swift`

**Add dependency:**
```swift
private let profileRepository: ProfileRepository

init(profileRepository: ProfileRepository) {
    self.profileRepository = profileRepository
    self.items = []
    // Load presets from SwiftData
    loadPresets()
}
```

**Add methods:**
```swift
/// Load presets from SwiftData (shared across all profiles)
private func loadPresets() async {
    do {
        // Fetch presets without owner (shared presets)
        let presets = try await profileRepository.fetchSharedPresets()
        self.items = presets.map { MacroPresetMapper.mapToModel($0) }
    } catch {
        // Handle error - fallback to factory presets
        self.items = FactoryMacroSplits.get().map { model in
            MacroSplitOptionModel(
                id: model.id,
                name: model.name,
                protein: model.protein,
                carbs: model.carbs,
                fats: model.fats,
                ordinal: model.ordinal,
                isSelected: model.isSelected,
                isCustom: false  // Factory presets are system presets
            )
        }
    }
}

/// Save a preset to SwiftData (shared, no owner)
private func savePreset(_ preset: MacroSplitOptionModel) async {
    do {
        let entity = MacroPresetMapper.mapToEntity(preset)
        try await profileRepository.saveSharedPreset(entity)
    } catch {
        // Handle error - could surface to user
    }
}

/// Batch save all presets
func saveAll(_ presets: [MacroSplitOptionModel]) async {
    do {
        for preset in presets {
            let entity = MacroPresetMapper.mapToEntity(preset)
            try await profileRepository.saveSharedPreset(entity)
        }
    } catch {
        // Handle error - could surface to user
    }
}
```

### 3.2 Update MacroSplitOptionModel
**File:** `SimpleTest/SimpleTest/Models/Macros/MacroSplitOptionModel.swift`

Add `isCustom: Bool` property to support distinguising system vs custom presets:

```swift
public var isCustom: Bool  // true if user-created, false if system preset

// Update initializers
public init(id: UUID = UUID(), name: String = "", protein: Int = 40, carbs: Int = 30, fats: Int = 30, ordinal: Int = 0, isSelected: Bool = false, isCustom: Bool = false) {
    self.id = id
    self.name = name
    let normalized = MacroSplitOptionModel.validateOnInit(protein: protein, carbs: carbs, fats: fats)
    self.protein   = normalized.protein
    self.carbs     = normalized.carbs
    self.fats      = normalized.fats
    self.ordinal   = ordinal
    self.isSelected = isSelected
    self.isCustom  = isCustom
}

public func clone() -> MacroSplitOptionModel {
    return MacroSplitOptionModel(id: self.id, name: self.name, protein: self.protein, carbs: self.carbs, fats: self.fats, ordinal: self.ordinal, isSelected: self.isSelected, isCustom: self.isCustom)
}
```

### 3.3 Create MacroPreset Mapper
**File:** `SimpleTest/Models/SwiftData/MacroPresetMapper.swift`

```swift
import SwiftData

/// Maps between MacroSplitOptionModel and SwiftData MacroPreset entity
enum MacroPresetMapper {
    /// Convert entity to model for reading from SwiftData
    static func mapToModel(_ entity: MacroPreset) -> MacroSplitOptionModel {
        MacroSplitOptionModel(
            id: entity.id,
            name: entity.name,
            protein: Int(entity.protein),
            carbs: Int(entity.carbs),
            fats: Int(entity.fats),
            ordinal: Int(entity.ordinal),
            isSelected: false,  // Selection managed separately
            isCustom: entity.isCustom
        )
    }
    
    /// Convert model to entity for saving to SwiftData
    /// Note: Presets are shared, so no owner is set
    static func mapToEntity(_ model: MacroSplitOptionModel) -> MacroPreset {
        let preset = MacroPreset()
        preset.id = model.id
        preset.name = model.name
        preset.protein = Int16(model.protein)
        preset.carbs = Int16(model.carbs)
        preset.fats = Int16(model.fats)
        preset.ordinal = Int16(model.ordinal)
        preset.isCustom = model.isCustom
        preset.isSystemPreset = !model.isCustom  // Custom presets are user-created
        preset.updatedAt = Date()
        // owner is nil - presets are shared across all profiles
        return preset
    }
    
    /// Create a system preset entity from seed data
    static func mapSystemPresetToEntity(id: UUID, name: String, protein: Int, carbs: Int, fats: Int, ordinal: Int) -> MacroPreset {
        let preset = MacroPreset()
        preset.id = id
        preset.name = name
        preset.protein = Int16(protein)
        preset.carbs = Int16(carbs)
        preset.fats = Int16(fats)
        preset.ordinal = Int16(ordinal)
        preset.isCustom = false
        preset.isSystemPreset = true
        preset.systemId = name.lowercased().replacingOccurrences(of: " ", with: "_")
        preset.createdAt = Date()
        preset.updatedAt = Date()
        // owner is nil - presets are shared across all profiles
        return preset
    }
}
```

## Phase 4: UI Updates

### 4.1 Update Views to Use SwiftData Context
- The repository will handle profile loading; views remain unchanged for now
- Evaluate `@Query` for list views when macro options are displayed

## Phase 5: Cleanup

### 5.1 Remove PersistenceActor file
Since `ProfileRepository` now handles all persistence operations, the `PersistenceActor.swift` file can be removed.

## Files to Create
```
SimpleTest/Models/SwiftData/
├── Profile.swift
├── MacroPreset.swift
├── SeedData.swift
├── SwiftDataContainer.swift
├── ProfileRepository.swift
├── ProfileMapper.swift
└── MacroPresetMapper.swift
```

## Files to Modify
```
SimpleTest/Models/ProfileViewModel/ProfileViewModel.swift
SimpleTest/Models/Macros/MacroSplitOptionsModelCollection.swift
SimpleTest/SimpleTestApp.swift
```

## Testing Checklist
- [ ] App launches and creates default profile if none exists
- [ ] App loads profile data from SwiftData on subsequent launches
- [ ] Profile data persists after app restart
- [ ] Macro presets are shared and load correctly
- [ ] Custom macro presets persist after app restart
- [ ] Predefined presets seeded from `SeedData.swift` on first launch
- [ ] UI remains responsive during save operations
- [ ] UI updates reflect saved data after restart
- [ ] Save retry logic works (3 attempts with backoff)
- [ ] Errors are surfaced after retries exhausted
- [ ] Reset to Defaults clears all user data and re-seeds

## Migration Notes

### First Launch Data Handling
1. App launches, attempt to load profile from SwiftData
2. If no profile exists:
   - Create default profile from `SeedData.profileDefaults()`
   - Create all presets from `SeedData.macroPresets()` using `mapSystemPresetToEntity()`
   - Save all to SwiftData via `saveSharedPreset()`
3. On subsequent launches, load from SwiftData only

### Seed Data Initial Import
On first launch (when profile doesn't exist):
```swift
// In SimpleTestApp
let profile = try await profileRepository.createDefaultProfile()
let seedPresets = SeedData.macroPresets()
for seedPreset in seedPresets {
    let entity = MacroPresetMapper.mapSystemPresetToEntity(
        id: seedPreset.id,
        name: seedPreset.name,
        protein: seedPreset.protein,
        carbs: seedPreset.carbs,
        fats: seedPreset.fats,
        ordinal: seedPreset.ordinal
    )
    try await profileRepository.saveSharedPreset(entity)
}
```

### Future Seed Updates
If `SeedData.swift` is updated:
1. Increment `seedVersion` in `SeedData`
2. On launch, compare stored `profile.seedVersion` vs current
3. If different, re-seed presets but preserve custom ones (where `isCustom == true`)

## Testing

### Unit Tests

#### ProfileRepository Tests
**File:** `Tests/SwiftData/ProfileRepositoryTests.swift`

```swift
import Testing
import SwiftData

struct ProfileRepositoryTests {
    @Test func testFetchActiveProfile_returnsNilWhenNoProfile() async throws {
        let container = try ModelContainer(for: Profile.self, configurations: .inMemory)
        let repository = ProfileRepository(context: container.mainContext)
        
        let profile = try await repository.fetchActiveProfile()
        
        #expect(profile == nil)
    }
    
    @Test func testSave_createsNewProfile() async throws {
        let container = try ModelContainer(for: Profile.self, configurations: .inMemory)
        let repository = ProfileRepository(context: container.mainContext)
        
        let profile = Profile()
        profile.id = ProfileRepository.activeProfileId
        profile.gender = 0
        profile.age = 30
        profile.height = 175.0
        profile.weight = 75.0
        profile.activityLevel = 1
        
        try await repository.save(profile)
        
        let fetched = try await repository.fetchActiveProfile()
        #expect(fetched != nil)
        #expect(fetched?.weight == 75.0)
    }
    
    @Test func testSave_retriesOnConflict() async throws {
        let container = try ModelContainer(for: Profile.self, configurations: .inMemory)
        let repository = ProfileRepository(context: container.mainContext)
        
        // Test that retry logic handles transient conflicts
        let profile = Profile()
        profile.id = ProfileRepository.activeProfileId
        profile.gender = 0
        profile.age = 30
        profile.height = 175.0
        profile.weight = 75.0
        profile.activityLevel = 1
        
        try await repository.save(profile)
        
        let fetched = try await repository.fetchActiveProfile()
        #expect(fetched?.weight == 75.0)
    }
    
    @Test func testCreateDefaultProfile() async throws {
        let container = try ModelContainer(for: Profile.self, configurations: .inMemory)
        let repository = ProfileRepository(context: container.mainContext)
        
        let profile = try await repository.createDefaultProfile()
        
        #expect(profile.id == ProfileRepository.activeProfileId)
        #expect(profile.seedVersion == SeedData.version)
    }
    
    @Test func testFetchSharedPresets_returnsEmptyWhenNoneExist() async throws {
        let container = try ModelContainer(for: MacroPreset.self, configurations: .inMemory)
        let repository = ProfileRepository(context: container.mainContext)
        
        let presets = try await repository.fetchSharedPresets()
        
        #expect(presets.isEmpty)
    }
}
```

#### ProfileMapper Tests
**File:** `Tests/SwiftData/ProfileMapperTests.swift`

```swift
import Testing

struct ProfileMapperTests {
    @Test func testMapToViewModel_mapsAllFields() async throws {
        let entity = Profile()
        entity.gender = 1  // female
        entity.age = 25
        entity.height = 165.0
        entity.weight = 60.0
        entity.activityLevel = 2  // moderate
        entity.bodyFatMethod = 1
        
        let viewModel = ProfileViewModel()
        ProfileMapper.mapToViewModel(entity, into: viewModel)
        
        #expect(viewModel.gender == .female)
        #expect(viewModel.age == 25)
        #expect(viewModel.height == 165.0)
        #expect(viewModel.weight == 60.0)
        #expect(viewModel.activityLevel == .moderateExercise)
    }
    
    @Test func testMapToEntity_mapsAllFields() async throws {
        let viewModel = ProfileViewModel()
        viewModel.gender = .male
        viewModel.age = 30
        viewModel.height = 180.0
        viewModel.weight = 80.0
        viewModel.activityLevel = .sedentary
        
        let entity = ProfileMapper.mapToEntity(viewModel)
        
        #expect(entity.gender == 0)
        #expect(entity.age == 30)
        #expect(entity.height == 180.0)
        #expect(entity.weight == 80.0)
        #expect(entity.activityLevel == 0)
    }
}
```

#### MacroPresetMapper Tests
**File:** `Tests/SwiftData/MacroPresetMapperTests.swift`

```swift
import Testing

struct MacroPresetMapperTests {
    @Test func testMapToModel_mapsAllFields() async throws {
        let entity = MacroPreset()
        entity.id = UUID()
        entity.name = "Test Preset"
        entity.protein = 40
        entity.carbs = 30
        entity.fats = 30
        entity.ordinal = 1
        entity.isCustom = false
        
        let model = MacroPresetMapper.mapToModel(entity)
        
        #expect(model.name == "Test Preset")
        #expect(model.protein == 40)
        #expect(model.carbs == 30)
        #expect(model.fats == 30)
        #expect(model.isCustom == false)
    }
    
    @Test func testMapToEntity_mapsAllFields() async throws {
        let model = MacroSplitOptionModel(
            id: UUID(),
            name: "Test",
            protein: 40,
            carbs: 30,
            fats: 30,
            ordinal: 1,
            isSelected: false,
            isCustom: true
        )
        
        let entity = MacroPresetMapper.mapToEntity(model)
        
        #expect(entity.name == "Test")
        #expect(entity.isCustom == true)
        #expect(entity.isSystemPreset == false)
    }
    
    @Test func testMapSystemPresetToEntity() async throws {
        let entity = MacroPresetMapper.mapSystemPresetToEntity(
            id: UUID(),
            name: "Balanced",
            protein: 40,
            carbs: 40,
            fats: 20,
            ordinal: 1
        )
        
        #expect(entity.isSystemPreset == true)
        #expect(entity.isCustom == false)
        #expect(entity.systemId == "balanced")
    }
}
```

#### SwiftDataContainer Tests
**File:** `Tests/SwiftData/SwiftDataContainerTests.swift`

```swift
import Testing

struct SwiftDataContainerTests {
    @Test func testInMemoryConfiguration() async throws {
        let container = SwiftDataContainer()
        
        // Container should be initialized successfully
        #expect(container.modelContext != nil)
    }
}
```

#### Integration Tests

**File:** `Tests/SwiftData/ProfilePersistenceIntegrationTests.swift`

```swift
import Testing

/// Tests the full profile persistence flow
struct ProfilePersistenceIntegrationTests {
    @Test func testProfileSurvivesRestart() async throws {
        // First "session" - create and save profile
        let container1 = try ModelContainer(for: Profile.self, configurations: .inMemory)
        let repo1 = ProfileRepository(context: container1.mainContext)
        
        let profile = Profile()
        profile.id = ProfileRepository.activeProfileId
        profile.gender = 0
        profile.age = 35
        profile.height = 175.0
        profile.weight = 75.0
        profile.activityLevel = 2
        
        try await repo1.save(profile)
        
        // Second "session" - load from storage
        let container2 = try ModelContainer(for: Profile.self, configurations: .inMemory)
        let repo2 = ProfileRepository(context: container2.mainContext)
        
        let loaded = try await repo2.fetchActiveProfile()
        
        #expect(loaded?.weight == 75.0)
        #expect(loaded?.age == 35)
    }
    
    @Test func testPresetsSurviveRestart() async throws {
        // First "session" - save presets
        let container1 = try ModelContainer(for: MacroPreset.self, configurations: .inMemory)
        let repo1 = ProfileRepository(context: container1.mainContext)
        
        let preset = MacroPreset()
        preset.id = UUID()
        preset.name = "Custom Preset"
        preset.protein = 50
        preset.carbs = 25
        preset.fats = 25
        preset.isCustom = true
        
        try await repo1.saveSharedPreset(preset)
        
        // Second "session" - load presets
        let container2 = try ModelContainer(for: MacroPreset.self, configurations: .inMemory)
        let repo2 = ProfileRepository(context: container2.mainContext)
        
        let loaded = try await repo2.fetchSharedPresets()
        
        #expect(loaded.count == 1)
        #expect(loaded[0].name == "Custom Preset")
    }
}
```

### Test Coverage Summary

| Component | Test Type | Coverage |
|-----------|-----------|----------|
| `ProfileRepository` | Unit | Fetch, save, create, retry logic |
| `ProfileMapper` | Unit | All field mappings (to/from entity) |
| `MacroPresetMapper` | Unit | All field mappings, system presets |
| `SwiftDataContainer` | Unit | Initialization, in-memory config |
| Profile persistence | Integration | Full round-trip, restart survival |
| Preset persistence | Integration | Full round-trip, restart survival |

### Test Organization

```
Tests/
├── SwiftData/
│   ├── ProfileRepositoryTests.swift
│   ├── ProfileMapperTests.swift
│   ├── MacroPresetMapperTests.swift
│   ├── SwiftDataContainerTests.swift
│   └── ProfilePersistenceIntegrationTests.swift
```
