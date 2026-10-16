# Story 017: SwiftData Persistence Fixes

**Objective:** Make preset and profile persistence work end to end. Story 014 added the SwiftData models and repository, but the UI never used them reliably, so edits, new macros and deletions are lost on relaunch or don't appear.

## Reported Bugs

1. Edit Presets → change a macro split → Save → relaunch: the change is gone.
2. Maintain Macros → Add → Save: the new macro does not appear in the list.

## Root Causes (from code review)

| # | Cause | Location |
|---|-------|----------|
| 1 | `MacroSplitOptionsModelCollection` is created inline in `ContentView.body` from `FactoryMacroSplits.get()`: no repository, never loaded, and rebuilt on every re-render | `ContentView.swift` |
| 2 | Editor Save always calls `collection.update`, which silently ignores unknown items, so new macros are never added | `MacroEditViewPage.swift`, collection `update` |
| 3 | `ProfileRepository.savePreset` always calls `context.insert`, so edits create duplicate rows (no uniqueness on `id`) | `ProfileRepository.swift` |
| 4 | `remove` only deletes from memory | collection `remove` |
| 5 | `saveToSwiftData` builds a new, never-inserted `Profile` on every save, so nothing is persisted and the id is random (never matches `activeProfileId`) | `ProfileViewModel.swift`, `ProfileMapper` |
| 6 | No first-launch seeding of factory presets into the store | collection `loadPresets` |
| 7 | Selected macro (`selectedMacroId`) and several profile fields (`bodyFatPercentageMethod`, uom, calorie adjustment) are not persisted | `Profile`, `ProfileMapper` |
| 8 | Preset calories hardcoded to 2000 though they are derived; secondary breakdown fields unused | `MacroPresetMapper`, `MacroPreset` |

## User Scenarios

### Presets
- **S1 First launch:** Given a fresh install, when the app opens, the seven factory presets are shown in Maintain Macros and stored in SwiftData.
- **S2 Edit persists:** Given a preset, when I change its name or split and Save, the list and main screen show the new values; after force-quit and relaunch they are still there, and no duplicate exists.
- **S3 Add persists:** Given Maintain Macros, when I tap Add, enter a valid name and a split totalling 100% and Save, the new macro appears in the list (marked custom) immediately and after relaunch.
- **S4 Cancel/invalid:** Cancel or an invalid split (name empty or total ≠ 100) saves nothing.
- **S5 Delete persists:** Deleting a macro removes it from the list and from the store; it does not return after relaunch.
- **S6 Reorder persists:** Drag-reordering is kept after relaunch.
- **S7 Selected macro:** Editing the currently selected macro updates the main screen results; the selected macro is still selected after relaunch.
- **S8 Deleting the selected macro:** Selection falls back to the first remaining macro (or Balanced); the main screen does not break.
- **S9 Factory presets not re-seeded:** If the user deleted or edited a factory preset, relaunch does not restore or overwrite it (seed only when the store is empty).

### Profile
- **S10 Profile persists:** Age, gender, height, weight, activity level and body fat settings entered by the user are restored after relaunch, within about a second of the last change.
- **S11 Single profile:** Repeated edits update one stored profile, never create more.

- **S13 Reset to defaults:** Given the system menu, when I choose "Reset Macro Presets to Defaults" and confirm, all presets (edited, deleted and custom) are replaced by the seven factory presets, in the store as well as the list. The selected macro stays selected if it still exists, else falls back to Balanced. Cancelling the confirmation changes nothing. Profile data is untouched.

### Robustness
- **S12 Store failure:** If a save or load fails, the app keeps working in memory and logs the error. It must not crash or lose the on-screen data.

## Acceptance Criteria

- One shared `MacroSplitOptionsModelCollection` instance, backed by the repository, injected via the environment and loaded at launch.
- Repository operations: upsert preset by `id`, delete preset, fetch ordered presets, seed-if-empty, upsert single active profile.
- Add vs edit handled explicitly by the editor and collection.
- Persist `selectedMacroId` and the remaining profile fields (schema changes are free: the app is not distributed, so no migration is required; delete the app to clear old stores).
- Calories are derived from the TDEE calculation and are not stored. Remove the placeholder 2000 and the calories fields from `MacroPreset`/`MacroBreakdown`.
- System menu has a "Reset Macro Presets to Defaults" action with a confirmation, backed by a repository/collection `resetToDefaults()`.
- No duplicate rows for the same preset or profile id, verified by tests.

## Testing

Unit tests use an in-memory `SwiftDataContainer(isInMemory: true)`, with a second context or container reload to simulate relaunch:
- [ ] Seed on empty store; no re-seed when non-empty
- [ ] Add, update and delete round-trip through the repository, with no duplicates
- [ ] Collection `update` of an unknown item adds it
- [ ] Reorder persists ordinals
- [ ] Profile save twice produces exactly one `Profile` with `activeProfileId`
- [ ] Selected macro id round-trips
- [ ] Manual: scenarios S1–S10 on simulator, with a relaunch between steps

## Status

Implemented on `features/story-017-swiftdata-persistence-fixes` (plan phases 1-5b). All unit tests pass, including the new `SwiftDataPersistenceTests`. Manual simulator walkthrough (S1-S10, S13) is still pending.

Defects found while testing, all fixed:
- `ProfileMapper.mapToViewModel` created a new `ProfileViewModel`, whose init starts another load, so once a profile was stored loading recursed forever. It is replaced by `ProfileMapper.apply(_:to:)`.
- `ProfileRepository` now owns its `ModelContainer`: a context traps if its container is deallocated (this crashed the test host).
- In-memory containers get unique names so test containers stay isolated, and `SwiftDataContainer.shared` is in-memory under XCTest.

## Open Questions

Resolved:
1. Factory presets stay user-deletable; recovery is via Reset to Defaults (S13).
2. Reset to defaults is in scope, from the system menu.
3. Calories are derived from the calculation, so they are not stored. Remove the fields.

**Dependencies:** Story 014 (persistence foundation), Story 016 (editor flow).
