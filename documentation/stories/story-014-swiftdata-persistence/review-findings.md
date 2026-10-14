# Review Findings: Story 014 — SwiftData Persistence

**Generated:** 2026-10-14
**Reviewers:** 4 independent passes (Schema, Architecture, Consistency, Integration)
**Total:** 42 findings — 13 high, 16 medium, 13 low

Each finding includes a status field (`open`, `fixed`, `wontfix`, `deferred`) to track resolution.

---

## High Severity

### H1 — `isCustom` and `isSystemPreset` are logically redundant
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **wontfix** — agreed, remove `isSystemPreset`, keep `isCustom` only |
| Where | MacroPreset schema (story.md & plan.md) |

`MacroPreset` declares both `isCustom: Bool` and `isSystemPreset: Bool`. The mapper confirms they are inverses: `isSystemPreset = !isCustom`. Storing both wastes space and creates a consistency risk if one path sets `isCustom` without updating `isSystemPreset`.

**Resolution:** Remove `isSystemPreset` as a stored attribute. Derive via computed property `var isSystemPreset: Bool { !isCustom }`.

---

### H2 — `createdAt` is never set in `ProfileMapper.mapToEntity`
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **acknowledged** — will fix during implementation |
| Where | ProfileMapper (plan.md Phase 2.2) |

`ProfileMapper.mapToEntity` sets `updatedAt = Date()` but has a comment `// createdAt is set on first creation` with no corresponding code. When updating an existing profile, the mapper creates a fresh `Profile()` with `createdAt` left at its default (Unix epoch 1970-01-01), silently overwriting the original creation timestamp on every save.

**Resolution:** Preserve `createdAt` when the entity already exists, or set it in the mapper for new entities.

---

### H3 — ProfileRepository actor holds `ModelContext` which is not thread-safe
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | ~~open~~ **acknowledged** — use `@MainActor class` |
| Where | ProfileRepository (plan.md Phase 1.3) |

`ProfileRepository` is declared as an `actor` with a `ModelContext` property. `ModelContext` is NOT thread-safe and must be used on the main thread. Actors execute on arbitrary threads determined by the Swift concurrency runtime. Every method (`fetchActiveProfile`, `fetchSharedPresets`, `save`, `createDefaultProfile`) will run on the actor's isolated queue, which may be a background thread. This will cause runtime crashes or data corruption.

**Resolution:** Replace `actor` with `@MainActor class`.

---

### H4 — `Task.sleep(for: .seconds(...))` will not compile
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | ~~open~~ **acknowledged** — fix Task.sleep API call |
| Where | `triggerSave()` (plan.md Phase 2.1, line ~239) |

`Task.sleep(nanoseconds: UInt64)` is the only available signature. There is no `Task.sleep(for: Duration)` overload. The code `try? await Task.sleep(for: .seconds(saveDelay))` will be a compilation error. Note that line 137 (retry backoff) uses the correct form: `Task.sleep(nanoseconds: UInt64(...))`.

**Resolution:** Use `try? await Task.sleep(nanoseconds: UInt64(saveDelay * 1_000_000_000))`.

---

### H5 — `context.insert(profile)` called on every save, including updates
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | ~~open~~ **acknowledged** — distinguish create vs update |
| Where | `ProfileRepository.save()` (plan.md Phase 1.3) |

`context.insert(profile)` is called unconditionally. `insert()` registers an object with the context for the first time. If the profile was already loaded from the context (e.g., via `fetchActiveProfile`), it is already tracked. Calling `insert()` again on an already-tracked object causes either a duplicate entry or an exception.

**Resolution:** Only `insert()` new entities; for updates, mutate the existing entity and call `context.save()`.

---

### H6 — `MacroSplitOptionsModelCollection` sync init cannot call async `loadPresets()`
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | ~~open~~ **acknowledged** — add async load method |
| Where | `MacroSplitOptionsModelCollection` (plan.md Phase 3.1) |

The init calls `loadPresets()` at line 370, but `loadPresets()` is declared `async`. Synchronous initializers cannot call async functions. A fire-and-forget `Task {}` inside init is unsafe because the task can be detached from the object lifetime.

**Resolution:** Provide an async load method. Macro split info is needed almost immediately, so the caller (e.g., `SimpleTestApp`) will await the load before the UI consumes the collection.

---

### H7 — Story and Plan have conflicting schema definitions for MacroPreset
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | ~~open~~ **resolved** — presets are a shared catalog, no owner relationship |
| Where | story.md lines 114-129 vs plan.md lines 36-52 |

Story defines `MacroPreset` with `weak var owner: Profile?` and `Profile` with `@Relationship` to presets. Plan explicitly removes these relationships ("presets are shared"). This is an unresolved design decision: if relationships exist, fetchSharedPresets can use $0.owner == nil; if not, that predicate references a nonexistent field. The documents contradict each other and must be aligned before coding.

**Resolution:** See H7. Presets are a shared catalog.

---

### H8 — Profile-to-MacroPreset relationship defined in Story but removed in Plan
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — same root as H7, presets are shared |
| Where | story.md lines 106-128 vs plan.md lines 28-29, 51-52 |

(Same root issue as H7, confirmed by a second reviewer.) Story defines a one-to-many relationship with inverse; plan explicitly removes both sides with "presets are shared across all profiles, no owner relationship."

**Resolution:** See H7. Presets are a shared catalog.

---

### H9 — `fetchSharedPresets` predicate references non-existent `owner` field — compile error
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — no owner field needed, fetch all presets |
| Where | `ProfileRepository` (plan.md line ~119) |

`#Predicate { $0.owner == nil }` — the plan's own `MacroPreset` schema has no `owner` property. Since the plan deliberately removed the relationship, this predicate is incorrect.

**Resolution:** Use `FetchDescriptor<MacroPreset>()` with no predicate since all presets are shared.

---

### H10 — Story lists `PersistenceActor.swift` for creation; Plan never creates it
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — ProfileRepository absorbed PersistenceActor responsibilities |
| Where | story.md line 76 vs plan.md Phase 5 (lines 515-516) |

Story lists `PersistenceActor.swift` as a file to create. Story decisions (items 3, 7) reference it for background operations and reset logic. Plan Phase 5 says to remove it because ProfileRepository handles the work. A developer following the story would create a file the plan then deletes.

**Resolution:** ProfileRepository (as `@MainActor class`) absorbs all PersistenceActor responsibilities. Story.md updated to match.

---

### H11 — Integration restart-survival tests use `.inMemory` containers and will always fail
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | ~~open~~ **acknowledged** — fix tests with disk-backed containers |
| Where | `ProfilePersistenceIntegrationTests` (both docs) |

Both `testProfileSurvivesRestart` and `testPresetsSurviveRestart` create two separate `ModelContainer` instances with `configurations: .inMemory`. In-memory stores are ephemeral and isolated per instance — the second container will never see data saved to the first. The tests are misleadingly named.

**Resolution:** Use a real on-disk container with a temporary directory for integration tests, with clean-up code to remove the temp directory after each test.

---

### H12 — ProfileMapper tests assume parameterless init but plan adds required DI parameter
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | ~~open~~ **acknowledged** — use in-memory container for mapper tests |
| Where | `ProfileMapperTests` (both docs) |

Both `testMapToViewModel_mapsAllFields` and `testMapToEntity_mapsAllFields` instantiate `ProfileViewModel` with no arguments. The plan (Phase 2.1) changes the init to require `profileRepository: ProfileRepository`. Compile break.

**Resolution:** Mapper tests create a real `ProfileRepository` backed by an in-memory `ModelContainer`. Quick, works for field-conversion tests, no need for protocol abstraction yet. If ViewModel grows more complex later, introduce a `ProfilePersistence` protocol for fakes.

---

### H13 — `MacroSplitOptionsModelCollection` init signature change breaks all existing consumers
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | ~~open~~ **acknowledged** — keep `init(items:)`, add optional repository |
| Where | plan.md Phase 3.1 |

The current code has `init()` and `init(items:)`. The plan adds a required `init(profileRepository:)`. At minimum, `syncSelectedMacro()` in ProfileViewModel calls `MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())` directly. Any view or view model that instantiates this class will break. The plan does not account for updating all call sites.

**Resolution:** Keep `init(items:)` backward-compatible. Add repository as an optional injected dependency (`init?(profileRepository: items:)`). New persistence-aware callers inject the repository; existing callers keep working unchanged.

---

## Medium Severity

### M1 — `seedVersion` mismatch handler is not assigned to a component
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **resolved** — assigned to app launch in Phase 2.3 |
| Where | plan.md Migration Notes |

The plan documents a re-seed flow (compare stored `seedVersion` vs current, re-seed if different) but no component is responsible for executing it. `SwiftDataContainer` initializes the container but does not own business logic. `ProfileRepository` manages CRUD.

**Resolution:** Phase 2.3 (app initialization) now handles seed version check and re-seeding.

---

### M2 — `updatedAt` responsibility split between mapper and caller is unclear
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **resolved** — mapper owns the timestamp |
| Where | ProfileMapper & MacroPresetMapper (plan.md) |

Both mappers set `updatedAt = Date()`. If a caller (`ProfileRepository.save`) also touches `updatedAt`, the value could be set at the wrong layer, making the audit trail unreliable.

**Resolution:** Mapper layer owns `updatedAt` — set consistently in `mapToEntity()` before save.

---

### M3 — No index on `systemId` for system preset lookups
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **resolved** — will add during implementation |
| Where | MacroPreset schema |

The re-seed flow needs to identify existing system presets by `systemId` to avoid duplicating them. Without `@Attribute(.index)` on `systemId`, every re-seed does a full table scan.

**Resolution:** Add `@Attribute(.index)` to `systemId` during implementation.

---

### M4 — No explicit `@Model` initializer defined
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **resolved** — will add during implementation |
| Where | Profile & MacroPreset schemas |

SwiftData's macro generates a parameterless `init()`. The plan shows `Profile(id:..., gender:..., ...)` which implies a parameterized init, but the schema code has none. A designated initializer would make the contract explicit and prevent partial entities.

**Resolution:** Add explicit initializers with all required parameters during implementation.

---

### M5 — Re-seed flow documented but has no call site wired into any phase
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — wired into Phase 2.3 app launch |
| Where | plan.md Migration Notes vs Phase list |

The seeding code is shown in Migration Notes but no phase describes calling it. Phase 2.3 (App Initialization) says "attempt to load profile from SwiftData; if no profile exists, create default and save" but does not mention seeding macro presets.

**Resolution:** Phase 2.3 now includes seed data initialization on first launch.

---

### M6 — "Reset to Defaults" decided in Story but no phase implements it
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — added to Phase 4.1 System Screen |
| Where | story.md Decisions #10 vs plan.md phases |

Story Decisions item 10 says to implement "Reset to Defaults". The plan's testing checklist includes it as a test item. However, no phase describes implementing the reset feature and `ProfileRepository` has no reset method.

**Resolution:** Phase 4.1 adds a Database view with status display and "Reset to Defaults" button linked from the system screen.

---

### M7 — `@Query` open question in Story unanswered in Plan
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — @Query not used in the app |
| Where | story.md line 163 vs plan.md Phase 4 |

Story asks "Should we use SwiftUI's `@Query` property wrapper for list views?" Plan Phase 4 says "Evaluate `@Query` for list views when macro options are displayed" — defers rather than answers.

**Resolution:** `@Query` is not used in the app. Repository handles all data loading.

---

### M8 — Seed data initialization not wired into any phase's implementation
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — same as M5, wired into Phase 2.3 |
| Where | plan.md Phases 1-4 |

(Duplicates M5 from a different angle — confirmed by two reviewers.)

**Resolution:** See M5.

---

### M9 — Plan "Files to Modify" section omits `MacroSplitOptionModel.swift`
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — added to "Files to Modify" |
| Where | plan.md lines 530-535 |

Phase 3.1 adds `isCustom: Bool` to this model, but the summary section at the end of the plan does not list it as a file to modify.

**Resolution:** Added to "Files to Modify" list.

---

### M10 — File path inconsistency between Story and Plan
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — all paths now prefixed with `SimpleTest/` |
| Where | story.md file table vs plan.md file paths |

Story uses `Models/SwiftData/Profile.swift`. Plan uses `SimpleTest/Models/SwiftData/Profile.swift`. Need to clarify whether story paths are relative to the target directory.

**Resolution:** All paths now use `SimpleTest/Models/SwiftData/...` convention.

---

### M11 — `SwiftDataContainer` claims test support but provides no in-memory constructor
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — added `init(isInMemory:)` parameter |
| Where | plan.md lines 175, 180-204 |

Plan line 175 says "Support in-memory store for tests." The container implementation has a private initializer with no parameter for test configuration.

**Resolution:** Container now accepts `isInMemory: Bool` parameter for test configuration.

---

### M12 — `SwiftDataContainer` static singleton has initialization timing risk
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | ~~open~~ **resolved** — container initialized early on main thread in Phase 2.3 |
| Where | `SwiftDataContainer` (plan.md Phase 1.4) |

Swift static properties are lazily initialized on first access. `ModelContainer` initialization should happen on the main thread. If `SwiftDataContainer.shared` is accessed from a background context before the main thread reaches `SimpleTestApp.body`, the container could initialize on a non-main thread.

**Resolution:** Container is explicitly initialized on the main thread during app launch (Phase 2.3).

---

### M13 — No test covers the throttled save cancellation path
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | ~~open~~ **resolved** — test will be added during implementation |
| Where | Test plan |

The throttled save pattern (cancel previous task, start new one) is a key UX feature but has no test coverage.

**Resolution:** Add test verifying rapid changes result in only one save after the delay.

---

### M14 — No test covers `seedVersion` mismatch / re-seeding logic
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | ~~open~~ **resolved** — test will be added during implementation |
| Where | Test plan |

The plan describes seed version drift detection but no test exercises it.

**Resolution:** Add test simulating a version bump and verifying re-seeding.

---

### M15 — `ProfileRepository.save()` retry test doesn't simulate any actual failure
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | ~~open~~ **resolved** — test will inject failure during implementation |
| Where | `ProfileRepositoryTests` |

The `testSave_retriesOnConflict` test just saves a profile successfully — it does not inject any failure to exercise the retry logic.

**Resolution:** Test will inject a failing `context.save()` that recovers on retry.

---

### M16 — Test code is nearly duplicated between Story and Plan
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — plan.md is the canonical test spec |
| Where | Both documents |

Story test sections (lines 202-469) and Plan test sections (lines 585-870) contain near-duplicate test code. If someone fixes a bug in one set, they must remember to fix it in the other.

**Resolution:** Plan.md contains the canonical test spec. Story.md test section will be removed or reduced to a reference.

---

## Low Severity

### L1 — `@Attribute(.unique)` on `id: UUID` is redundant
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **acknowledged** — remove redundant attribute |
| Where | Profile & MacroPreset schemas |

SwiftData automatically treats a `var id: UUID` property as the model's identifier, enforcing uniqueness at the framework level. Adding `@Attribute(.unique)` duplicates this constraint and adds a tiny SQLite index overhead.

**Resolution:** Remove `@Attribute(.unique)` from both schemas.

---

### L2 — Int16 range headroom is fine for all fields
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | open |
| Where | Schema types |

Int16 max is 32,767. Age, activity level, and macro percentages are fine. Height and weight use `Double`, so no overflow risk.

**Recommendation:** No action needed — noted for completeness.

---

### L3 — `ordinal` has no guard against negative values
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | **fixed** — changed type to `Int` |
| Where | MacroPreset schema |

`ordinal` as `Int16` allows negative values. The mapper casts `Int` to `Int16` with no clamping.

**Resolution:** Changed type to `Int` to avoid need for negative value guards.

---

### L4 — `print()` used for error logging in production code
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | **fixed** — replaced with `os.Logger.default.error()` |
| Where | ProfileViewModel `saveToSwiftData()` (plan.md line ~263) |

`print("Failed to save profile: \(error)")` sends to standard output, not captured in production App Store builds.

**Resolution:** Replaced with `os.Logger.default.error()` for production logging.

---

### L5 — Mapper has inconsistent direction
| Field | Value |
|-------|-------|
| Reviewer | Architecture |
| Status | ~~open~~ **acknowledged** — align both to return new instances |
| Where | ProfileMapper |

`mapToViewModel` mutates a `ProfileViewModel` in place; `mapToEntity` returns a new `Profile`. Not a bug, but a maintenance risk.

**Resolution:** Both methods will return new instances for consistency.

---

### L6 — Retry backoff labeled "exponential" but values are linear
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | **fixed** — renamed to "linear backoff" |
| Where | plan.md line ~113 |

`100_000_000 * attempt` produces 100ms, 200ms (linear). True exponential would be 100ms, 200ms, 400ms.

**Resolution:** Renamed comments to "linear backoff" to match actual implementation.

---

### L7 — `deinit { saveTask?.cancel() }` may not execute reliably
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | **fixed** — added note about `@Observable` deinit reliability |
| Where | ProfileViewModel (plan.md Phase 2.1) |

If `ProfileViewModel` uses Swift's `@Observable` macro (iOS 17+), deinit execution is not guaranteed in all scenarios.

**Resolution:** Added note about using a cancellation mechanism tied to the view lifecycle (`.onDisappear()`) for robust cancellation.

---

### L8 — Integration test naming is misleading
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | open |
| Where | `ProfilePersistenceIntegrationTests` |

Test names (`testProfileSurvivesRestart`) imply cross-container persistence but `.inMemory` containers are isolated. The names overstate what is tested.

**Recommendation:** Rename to `testProfileRoundTrip` / `testPresetRoundTrip` if keeping in-memory, or use disk-backed containers.

---

### L9 — No test for SwiftDataContainer `fatalError` error path
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | **fixed** — changed `fatalError` to `throw error` |
| Where | `SwiftDataContainerTests` |

The container's init has a `fatalError` branch on failure. This path is untested (and arguably untestable with `fatalError`).

**Resolution:** Changed `fatalError("Failed to initialize...")` to `throw error` for testability.

---

### L10 — `SwiftDataContainer` test asserts `modelContext != nil` which is always true
| Field | Value |
|-------|-------|
| Reviewer | Integration |
| Status | **fixed** — added container property, removed tautology |
| Where | `SwiftDataContainerTests` (plan.md line ~780) |

The test `#expect(container.modelContext != nil)` is a tautology — `modelContext` is a non-optional computed property.

**Resolution:** Made `container` property public and updated test to check both `container` and `profileRepository` are not nil.

---

### L11 — Story says to seed on first launch; Plan shows seeding code but not which phase calls it
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | open |
| Where | story.md vs plan.md phases |

(Same root as M5/M8 — third confirmation.)

---

### L12 — `isSystemPreset` derived value should be a computed property, not a stored attribute
| Field | Value |
|-------|-------|
| Reviewer | Schema |
| Status | ~~open~~ **resolved** — follow-on to H7/H8/H9, no owner field |
| Where | Profile & MacroPreset schemas |

`MacroPreset` declares both `isCustom: Bool` and `isSystemPreset: Bool`. The mapper confirms they are inverses: `isSystemPreset = !isCustom`. Storing both wastes space and creates a consistency risk if one path sets `isCustom` without updating `isSystemPreset`.

**Resolution:** Remove `isSystemPreset` as a stored attribute per H1. Derive via computed property `var isSystemPreset: Bool { !isCustom }`.

---

### L13 — Minor: `saveSharedPreset` name is misleading if presets are shared
| Field | Value |
|-------|-------|
| Reviewer | Consistency |
| Status | ~~open~~ **resolved** — renamed to `savePreset`/`fetchPresets` |
| Where | ProfileRepository naming |

The `saveSharedPreset` / `fetchSharedPresets` naming implies there might be "non-shared" presets, which conflicts with the single-profile design. A simpler name (`savePreset` / `fetchPresets`) avoids implying a future multi-profile distinction that doesn't exist yet.

**Resolution:** Renamed to `savePreset` / `fetchPresets` throughout plan.md.

---

## Duplicate / Overlapping Findings

Several findings address the same root cause and were flagged by multiple reviewers:

| Root Cause | Flagged By | Status |
|------------|-----------|--------|
| Story/Plan schema conflict (relationship vs no relationship) | H7, H8, H9 | Resolved — presets are shared |
| `isSystemPreset` redundancy | H1, L12 | Resolved — remove, derive instead |
| PersistenceActor consolidation | H10 | Resolved — ProfileRepository absorbs it |
| `seedVersion` handler not wired into any phase | M1, M5, M8, L11 | open |
| Integration tests structurally broken (in-memory) | H11, L8 | open |
| Mapper tests break with new DI parameter | H12, H13 | open |
| Test code duplicated between documents | M16 | open |

---

## Resolution Checklist

Copy this section into your task tracker or use it as a progress tracker:

```
[ ] H1  Remove isSystemPreset, keep isCustom only
[ ] H2  Preserve createdAt in ProfileMapper.mapToEntity
[ ] H3  Replace actor with @MainActor class for ProfileRepository
[ ] H4  Fix Task.sleep API call in triggerSave()
[ ] H5  Distinguish create vs update in save()
[ ] H6  Provide async factory for MacroSplitOptionsModelCollection
[ ] H7+H8  Align story.md and plan.md on preset ownership
[ ] H9  Fix fetchSharedPresets predicate
[ ] H10 Remove PersistenceActor from story file list
[ ] H11 Fix integration tests to use disk-backed containers
[ ] H12 Update mapper tests with repository mock
[ ] H13 Update all MacroSplitOptionsModelCollection call sites
[ ] M1  Assign seedVersion mismatch handler to a component
[ ] M2  Document updatedAt ownership
[ ] M3  Add index on systemId
[ ] M4  Add explicit @Model initializers
[ ] M5  Wire seeding into a phase
[ ] M6  Implement Reset to Defaults
[ ] M7  Resolve @Query decision
[ ] M9  Add MacroSplitOptionModel to "Files to Modify"
[ ] M10 Align file paths
[ ] M11 Add in-memory constructor for tests
[ ] M12 Ensure main-thread container initialization
[ ] M13 Add throttled save cancellation test
[ ] M14 Add seedVersion mismatch test
[ ] M15 Inject failure in retry test
[ ] M16 Deduplicate test code between documents
[ ] L1  Remove redundant @Attribute(.unique)
[ ] L3  Guard ordinal against negatives
[ ] L4  Replace print() with os.Logger
[ ] L5  Align mapper direction (mutate vs allocate)
[ ] L6  Fix backoff naming or formula
[ ] L7  Review deinit reliability
[ ] L9  Consider throwing instead of fatalError
[ ] L10 Fix tautology in container test
[ ] L13 Consider renaming saveSharedPreset
```
