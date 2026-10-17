# Plan: Story 021 — Multiple Profiles

Re-use the existing **macro-preset CRUD + list/editor pattern** (the closest analogue in the codebase)
and the storage foundation Story 014 left behind. The active profile re-points the *single* existing
`ProfileViewModel` rather than swapping the bound instance, keeping the architecture the whole view tree
is built on.

## Decisions

1. **Main profile identified by name** — The Main profile is the one with `name == "Main"`, not a fixed
   UUID. This allows flexibility and clearer semantics.
2. **Delete protection** — The Main profile cannot be deleted; also, the last remaining profile cannot
   be deleted (always keep at least one).
3. **No migration** — The app hasn't released yet; device wipe on upgrade is acceptable.

## Phase 1 — Data model & persistence (TDEEShared)

- **`Profile.swift`** — add `var name: String` (no default; required field). Story 014's *plan* carried
  `name: String?`; the implemented schema dropped it, so add it now.
- **`ProfileRepository.swift`** — remove the fixed `activeProfileId` (`:11`). Add:
  - `fetchMainProfile() -> Profile?` — fetch profile where `name == "Main"`
  - `fetchAllProfiles() -> [Profile]` (sorted: Main first, then by name)
  - `fetchProfile(byId: UUID) -> Profile?`
  - `createProfile(name: String) -> Profile` (new `UUID`, `SeedData.profileDefaults()`, `name`)
  - `deleteProfile(byId:)` — **guarded: refuses if profile is Main OR if it's the last profile**
- **`ProfileMapper.swift`** — thread `name` through both `apply(_:to:)` (`:9-21`) and
  `mapToEntity(_:existing:)` (`:26-59`).

## Phase 2 — Profile store (TDEEShared)

- **New `ProfileStore.swift`** — a small `@Observable @MainActor` object mirroring
  `MacroSplitOptionsModelCollection` (`TDEEShared/Models/Macros/MacroSplitOptionsModelCollection.swift`):
  holds the list of profile summaries (`id`, `name`, active flag), the in-session active profile id
  (defaulting to Main by fetching profile where `name == "Main"`), and CRUD (`add(name:)`, `delete`,
  `switch(to:)`). Delete is guarded: refuses Main profile or if it's the last profile.

## Phase 3 — View model (TDEEShared)

- **`ProfileViewModel.swift`** — add `var name: String` (from profile entity) and `var profileId: UUID`.
  - `load(profileId:)` — fetch profile **by `profileId`** (via `fetchProfile(byId:)`).
  - `saveToSwiftData()` — fetch existing entity **by `profileId`** and only create with `profileId`
    when none exists — drop the forced `activeProfileId` at `:216`.
  - Add `func switchProfile(to id: UUID)` — set `profileId`, cancel any pending save, reload that entity
    under the `isLoading` guard (so the re-pointed fields don't save into the wrong row), then
    `refreshResults()`.
  - **Keep `init(profileRepository:macroCollection:)` unchanged** so the ~30 existing construction
    call sites/tests keep compiling (uses a default profileId which gets overridden by load).

## Phase 4 — App wiring (TDEE)

- **`TDEEApp.swift`** (`:19-22`) — create the `ProfileStore` once as `@State` (alongside `profile` /
  `macroCollection`), inject it via `.environment` (like `macroCollection`, `ContentView.swift:101`).
- **`AppRoute.swift`** (`:9-16`) — add `case profiles` and a profile-editor route (mirror
  `.macroEditorCreate` / `.macroEditorEdit` at `:14-15`, or a single `.profileEditor(item:)` using the
  macro editor's `isNew` pattern).
- **`ContentView.swift`** — read the store from the environment; add the new routes to the
  `.navigationDestination` switch (`:83-98`): `.profiles` → `ProfileListViewPage`,
  `.profileEditor` → `ProfileEditViewPage`. Also add the **quick-switch** as a new
  `.topBarLeading` `ToolbarItem` in the existing `.toolbar { }` block (`:60-77`), beside the system menu
  — a `Menu`/button of profile names that calls `store.switch(to:)`.

## Phase 5 — UI (TDEE)

- **`UISystemPageView.swift`** — add a **"Profiles"** button to the *Navigation* section (`:17-27`),
  same pattern as *Maintain Macro Config* / *Theme* / *About* (`path.append(.profiles)`).
- **New `ProfileListViewPage/`** — copy `MacroOptionsListViewPage.swift`
  (`TDEE/Pages/MacroOptionsListViewPage/MacroOptionsListViewPage.swift`) + its
  `SubViews/MacroOptionsListCardView.swift` and `MacroOptionsListItemView.swift`. List profiles by name,
  mark the active one, **"Add"** toolbar button → create route; tap a row → `store.switch(to:)`.
- **New `ProfileEditViewPage/`** — copy `MacroEditViewPage.swift`
  (`TDEE/Pages/MacroEditPage/MacroEditViewPage.swift`) + its `DeleteConfirmationSheet` (`:129-195`):
  a `Form` with one **Name** `TextField` (`:38-41`), Cancel/Save toolbar (`:92-108`), and a destructive
  Delete guarded by `store.count <= 1` / "not the Main profile" (mirrors `:81`).
- **`UIMainView.swift`** — recompute-on-switch: add `.onChange(of: store.activeProfileId)` that runs the
  existing `recalculate()` (`:33-36`) and resets `calculationResult`/`isCalculating`; the per-field
  `.onChange` handlers (`:119-162`) don't fire across an instance re-point, so the switch must trigger the
  recompute here. (The switch *control* itself lives in `ContentView`'s toolbar — see Phase 4.)

## Phase 6 — Tests (TDEETests)

- **`SwiftDataPersistenceTests.swift`** — update `singleProfile()` to assert the **Main** profile
  persists (by `name == "Main"`); add cases: `createProfile` + `fetchAllProfiles`, `deleteProfile`
  (Main protected, last-profile protected), and a name round-trip. `profileRoundTrip()` keeps passing
  because the convenience `init()` still loads the active/Main profile.
- The ~30 `ProfileViewModel()` construction tests (`TDEETests.swift`, `CalculationParityTests.swift`,
  `ShareResultsModelTests.swift`, `ThemeTests.swift`) are **unaffected** because the existing `init`
  signature is unchanged.
- Follow the `implement-story` skill: run `xcodebuild -project TDEE.xcodeproj -scheme TDEE
  -configuration Debug test` after implementation.

## Files to create

```
TDEEShared/Models/SwiftData/ProfileStore.swift
TDEE/Pages/ProfileListPage/ProfileListViewPage.swift   (+ subviews, copied from MacroOptionsListViewPage)
TDEE/Pages/ProfileEditPage/ProfileEditViewPage.swift   (+ DeleteConfirmationSheet, copied from MacroEditViewPage)
```

## Files to modify

| File | Change |
|------|--------|
| `TDEEShared/Models/SwiftData/Profile.swift` | Add `name: String` |
| `TDEEShared/Models/SwiftData/ProfileRepository.swift` | `fetchMainProfile` / `fetchAllProfiles` / `fetchProfile(byId:)` / `createProfile(name:)` / `deleteProfile(byId:)` |
| `TDEEShared/Models/SwiftData/ProfileMapper.swift` | Thread `name` both directions |
| `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift` | `name`, `profileId`, `switchProfile(to:)`; load/save by id; keep old `init` |
| `TDEE/TDEEApp.swift` | Create + inject `ProfileStore` |
| `TDEE/ContentView.swift` | Read store; add `.profiles` / `.profileEditor` routes; quick-switch toolbar item (leading, next to system menu) |
| `TDEE/Enums/AppRoute.swift` | Add profile routes |
| `TDEE/Pages/SystemPage/UISystemPageView.swift` | "Profiles" entry |
| `TDEE/Pages/MainPage/UIMainView.swift` | Recompute-on-switch (the control itself is in `ContentView`'s toolbar) |
| `TDEETests/SwiftDataPersistenceTests.swift` | Update `singleProfile`; add CRUD + name round-trip |

## Testing checklist

- [ ] App opens to the **Main** profile
- [ ] Add a named profile, switch to it; main screen shows that person's data and recomputed TDEE/macros
- [ ] Switch back; first person's data returns
- [ ] Names + fields persist across relaunch; relaunch opens **Main**
- [ ] Main / only profile cannot be deleted; a non-Main profile can
- [ ] Existing single-profile + calculation tests pass; `singleProfile` updated
- [ ] Watch app unchanged; full test suite passes

## Risks

- **Re-pointing the single instance** — `switchProfile` must run under the `isLoading` guard so a
  re-pointed field's `didSet` doesn't save into the wrong row; and the main screen must recompute
  explicitly (its `.onChange` handlers won't fire on a new instance).
- **The `singleProfile` test** encodes the old invariant and will fail until updated.
- **Target / Xcode wiring** for the two new pages (folder membership) — the usual source of small build
  friction; mirror the macro pages' target membership.
