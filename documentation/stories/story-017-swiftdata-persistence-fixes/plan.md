# Plan: Story 017 - SwiftData Persistence Fixes

Branch: `features/story-017-swiftdata-persistence-fixes`

## Phase 0: Already done (commit 5535f1e, draft, untested)
- One repository-backed `MacroSplitOptionsModelCollection` in `ContentView`, loaded via `.task`
- Seed factory presets when the store is empty
- `ProfileRepository`: upsert preset by id, `deletePreset`, profile insert-if-unmanaged
- Collection `update` adds unknown items; `remove` deletes from the store
- `ProfileViewModel.saveToSwiftData` reuses the stored profile, id = `activeProfileId`

## Phase 1: Tests for Phase 0 (test-first review of the draft)
Add `SimpleTestTests/SwiftDataPersistenceTests.swift` using `SwiftDataContainer(isInMemory: true)` (`@MainActor`):
1. Seed: empty store gives 7 presets after `loadPresets`; a second `loadPresets` on a non-empty store does not re-seed or overwrite
2. Preset upsert: saving the same id twice leaves one row with the new values
3. Add via `update` of an unknown item: the item is added, `isCustom == true`, ordinals contiguous, persisted
4. Delete: removed from the collection and the store
5. Reorder: `move` persists ordinals
6. Profile: two `save` calls produce one `Profile` with `activeProfileId`
7. "Relaunch": a new collection over the same container sees the persisted state

Make the collection's persistence awaitable for tests (currently `Task {}` fire and forget): add `async` variants (`addAndSave`, `updateAndSave`, `removeAndSave`), with the sync methods wrapping them, or expose the last pending task.

## Phase 2: Review the draft for gaps
- `update` copies fields onto the existing model, then persists `item` (the editor clone). Verify `isCustom` and `ordinal` survive
- `loadPresets` error fallback: keep in-memory factory presets but log; make sure the fallback does not mask persistent failure (S12)
- `ProfileViewModel.loadFromSwiftData` runs async at init: confirm the load does not trigger a save that overwrites the stored profile with defaults (the `didSet` → `triggerSave` path). Add a `isLoading` guard if so
- `FactoryMacroSplits.Id.balanced` equals `activeProfileId` (11111111-...). Harmless (different entity types) but confirm and note it

## Phase 3: Delete behaviour (S8)
- When the removed macro is the selected one, set `selectedMacroId` to the first remaining item. The editor/list must do this via a collection callback, or `UIMainView` observes `collection.items`
- Guard against deleting the last remaining macro (disable delete, or reseed)

## Phase 4: Persist selection and missing profile fields (cause 7)
- Add to `Profile`: `selectedMacroId: UUID?`, `bodyFatMethodRaw`, `calorieAdjustmentMethodRaw`, `calorieAdjustment`. Use optional or defaulted properties so SwiftData lightweight migration works with existing installs
- Update `ProfileMapper` and `ProfileViewModel.loadFromSwiftData`
- Tests: round trip of each field; the migration case is checked manually (install the old build, then the new one)

## Phase 5: Remove stored calories (cause 8)
Calories are derived from the TDEE calculation, so they are not persisted.
- Remove `calories` from `MacroBreakdown` and `primaryCalories`/`secondaryCalories` from `MacroPreset`; drop the 2000 placeholder in `MacroPresetMapper`
- Remove the unused secondary breakdown fields too, and the unused `OptionMacroSplit` enum if nothing references it
- Schema change: removing stored properties is a lightweight migration in SwiftData. Verify by upgrading an install from the previous build (manual)
- Check nothing else reads preset calories (grep `primaryCalories`, `.calories`)

## Phase 5b: Reset to defaults (S13)
- Repository: `resetPresetsToDefaults()` deletes all `MacroPreset` rows and inserts `SeedData.macroPresets()` in one save
- Collection: `resetToDefaults() async` calls it, then reloads `items`; if the selected id is gone, the caller falls back to Balanced
- UI: add a "Reset Macro Presets to Defaults" row to `UISystemPageView` (system menu), using a destructive confirmation dialog (reuse the style of `DeleteConfirmationSheet`)
- Tests: after edits, adds and deletes, reset gives exactly the 7 factory presets with factory ids, both in the collection and after a reload; the profile is unchanged; selection fallback works

## Phase 6: Manual verification on simulator
Walk S1–S10 and S13 with a force-quit between steps; record results in `story.md`. Check there are no duplicate rows (log the preset count on load in a debug build).

## Phase 7: Wrap-up
- Full test run: `DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.3.app/Contents/Developer xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -destination 'platform=iOS Simulator,name=<device>' test`
- Mark story 017 Done in `documentation/stories/README.md`
- Merge into `develop` (see the implement-story skill)

## Risks
- Schema change breaks existing installs: mitigate with defaulted properties and a manual upgrade test
- Fire-and-forget saves racing with relaunch: mitigate by awaiting saves in tests, and saving immediately (not throttled) for presets
- Deleting the selected macro leaves a dangling `selectedMacroId`: Phase 3
