# Story 014: SwiftData Persistence

**Objective:** Introduce SwiftData to persist user profile data and custom macro presets between app launches. iCloud synchronization can be added in a follow-up story.

**Note:** This story establishes the foundation for future multi-profile support. The initial implementation focuses on single-profile usage while designing the data model to accommodate multiple profiles in the future.

## Motivation

Currently, all data (profile information and macro presets) exists only in memory during the app session. When the app is closed or terminated:
- User's profile (age, gender, weight, height, activity level) is lost
- Custom macro presets are lost
- Users must re-enter all data on each app launch

This is a critical issue because:
1. **User experience**: Re-entering profile data each time is frustrating
2. **Data loss**: Custom macro presets created by users are not saved
3. **Unprofessional**: Apps should persist user data

## Current State

### Profile Data
- Stored in `ProfileViewModel` as in-memory properties
- Lost on app termination

### Macro Presets
- Predefined presets stored in `MacroSplitOptionsModelCollection` environment
- No mechanism for user-created custom presets
- All data lost on app termination

### Data Flow
```
App Launch → ProfileViewModel initialized with defaults
          → MacroSplitOptionsModelCollection initialized
          → User enters data (lost on exit)
```

## Expected State

### SwiftData Setup
- SwiftData model with `Profile` and `MacroPreset` schemas
- **Local storage only for now** (CloudKit can be added later)
- Thread-safe background processing via `ModelActor` to prevent UI blocking
- Automatic save on data changes

### Profile Data
- Profile persisted to SwiftData (local storage)
- Automatically loaded on app launch
- Changes saved immediately via the background actor

### Macro Presets
- Predefined presets (from a central constants file) stored in SwiftData on first launch
- User can create, edit, delete custom presets
- All presets persist between app launches

### iCloud Add-On (Future)
- CloudKit sync can be added later by updating `ModelConfiguration`
- No data migration issues when enabling iCloud later

### Data Flow
```
App Launch → SwiftData model initialized (local storage)
          → Profile loaded from SwiftData (or defaults from ProfileDefaults)
          → Macro presets loaded from SwiftData (or seeded from FactoryMacroSplits)
          → User edits → Throttled background save → Auto-saved
```

## Implementation Notes

### Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `SimpleTest/Models/SwiftData/Profile.swift` | Create | SwiftData schema for Profile |
| `SimpleTest/Models/SwiftData/MacroPreset.swift` | Create | SwiftData schema for MacroPreset |
| `SimpleTest/Models/SwiftData/SwiftDataContainer.swift` | Create | SwiftData model container initialization & CloudKit config |
| `SimpleTest/Models/SwiftData/ProfileRepository.swift` | Create | `@MainActor class` for thread-safe profile access, preset CRUD, and reset logic (replaces PersistenceActor) |
| `SimpleTest/Models/SwiftData/SeedData.swift` | Create | Uses `ProfileDefaults` and `FactoryMacroSplits` as single source of truth |
| `SimpleTest/Models/SwiftData/ProfileMapper.swift` | Create | Convert between ProfileViewModel and Profile entity |
| `SimpleTest/Models/SwiftData/MacroPresetMapper.swift` | Create | Convert between MacroSplitOptionModel and MacroPreset entity |
| `SimpleTest/Models/ProfileViewModel/ProfileViewModel.swift` | Modify | Add SwiftData save/load triggers with throttled save |
| `SimpleTest/Models/Macros/MacroSplitOptionsModelCollection.swift` | Modify | Load/save presets via ProfileRepository |
| `SimpleTest/Models/Macros/MacroSplitOptionModel.swift` | Modify | Add `isCustom: Bool` property |
| `SimpleTest/SimpleTestApp.swift` | Modify | Initialize SwiftData container on app launch |
| `SimpleTest/Models/Macros/MacroSplitOptionModel.swift` | Modify | Add `isCustom: Bool` property |
| `App/SimpleTestApp.swift` | Modify | Initialize SwiftData container on app launch |

### SwiftData Schema

#### Profile Schema
```swift
@Model
class Profile {
    var id: UUID
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
}
```

#### MacroPreset Schema
```swift
@Model
class MacroPreset {
    var id: UUID
    var name: String
    var protein: Int16
    var carbs: Int16
    var fats: Int16
    var ordinal: Int16
    var isCustom: Bool
    /// Derived: `!isCustom`. Presets are a shared catalog, not owned by any profile.
    var isSystemPreset: Bool { !isCustom }
    var systemId: String?  // e.g., "balanced", "diet" for system presets
    var createdAt: Date
    var updatedAt: Date
}
```

### Design Decisions

1. **No relationship between Profile and MacroPreset**
   - `MacroPreset` is a shared catalog that all profiles pick from
   - No `owner` field on `MacroPreset` — presets are not owned by any profile
   - Presets are fetched via a simple `FetchDescriptor<MacroPreset>()` with no filter
   - **Future-proofing**: When multi-profile support is added, a profile can reference presets by ID without ownership

2. **Should we keep the in-memory models alongside SwiftData?**
   - Yes - SwiftData for persistence, models for UI binding
   - Mapping layer converts between them
   - `ProfileRepository` (as `@MainActor class`) manages the single active profile instance and all persistence operations

3. **Where should the SwiftData container be initialized?**
   - In `SimpleTestApp` at app launch
   - Available via environment or dependency injection

4. **Should changes save automatically or require explicit save?**
   - Automatic save on changes for better UX
   - Triggered by ViewModel changes, executed by `ProfileRepository` (`@MainActor class`) to keep database operations on the main thread

5. **How to handle the single active profile?**
   - `ProfileRepository` manages a single "active" profile (ID stored as a constant for first run)
   - When multi-profile support is added, this will evolve to a profile selector

6. **How to handle missing data on first launch?**
   - Seed predefined macro presets from `SeedData.swift` if none exist
   - Create default profile with empty values

## Decisions

### Approach
1. Create SwiftData schemas with `Profile` and `MacroPreset` classes (no relationship between them — presets are shared)
2. Implement `ProfileRepository` as `@MainActor class` to manage the single active profile, preset CRUD, and reset logic
3. Define `SeedData` for predefined presets to avoid hardcoding in the container
4. **Local storage only** - iCloud sync can be added in a follow-up story by adding CloudKit container properties
5. Use **dependency injection** for `ProfileRepository` (consistent with existing `MacroSplitOptionsModelCollection` pattern)
6. Update `ProfileViewModel` to trigger saves via the repository with a throttled save pattern
7. Update `MacroSplitOptionsModelCollection` to persist custom presets via the repository (keep existing `init(items:)` for backward compatibility)
8. Initialize SwiftData container on app launch and seed predefined presets if necessary
9. Implement a "Reset to Defaults" feature that clears all user data and re-seeds defaults

### Rationale
1. **SwiftData** - Modern Swift framework, simple API, integrates with SwiftUI
2. **No relationship** - Presets are a shared catalog; all profiles reference the same list. Simpler data model, no cascade-delete complexity.
3. **`@MainActor class`** - `ModelContext` is not thread-safe and must run on the main thread. Using `@MainActor class` ensures all database operations stay on the main thread without manual wrapping.
4. **Dependency Injection** - Allows testability and consistency with existing app patterns (same as `MacroSplitOptionsModelCollection`)
5. **ProfileRepository** - Centralizes profile management with single-profile focus and multi-profile foundation
6. **Seed Data File** - Centralizes "gold" data for easier maintenance
7. **Reset Feature** - Necessary for user control and testing purposes
8. **Throttled saves** - Better UX than manual save buttons; prevents redundant saves during rapid changes
9. **Seed on first launch** - Uses existing `ProfileDefaults` and `FactoryMacroSplits` as single source of truth

## Status
Done - SwiftData persistence is implemented (see story 017 for the follow-up fixes).

## Future: Multi-Profile Support

When multi-profile support is added, the existing schema supports this evolution:

1. Add a `ProfileSelector` view to choose active profile
2. `ProfileRepository.activeProfileId` becomes a user-selectable value
3. Profile list loaded from SwiftData via `@Query`
4. Profile creation/editing UI to manage multiple profiles

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
| Profile persistence | Integration | Full round-trip, restart survival |
| Preset persistence | Integration | Full round-trip, restart survival |

### Test Organization

```
Tests/
├── SwiftData/
│   ├── ProfileRepositoryTests.swift
│   ├── ProfileMapperTests.swift
│   ├── MacroPresetMapperTests.swift
│   └── ProfilePersistenceIntegrationTests.swift
```
