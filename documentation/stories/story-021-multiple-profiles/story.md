# Story 021: Multiple Profiles

**Objective:** Let the user keep one **Main** profile as the quick daily default and store additional named profiles for **different people**, switching between them within a session.

## Background

Story 014 (SwiftData Persistence) deliberately designed the storage layer to grow into multi-profile
support but shipped single-profile only. Its own plan lists the future work verbatim:

> 1. Add a `ProfileSelector` view to choose the active profile
> 2. `ProfileRepository.activeProfileId` becomes a user-selectable value
> 3. Profile list loaded from SwiftData
> 4. Profile creation/editing UI to manage multiple profiles

That is this story. Today the "single profile" assumption is hard-wired in a few tight places:

- `ProfileRepository.activeProfileId` is a **fixed UUID** (`11111111-1111-1111-1111-111111111111`,
  `TDEEShared/Models/SwiftData/ProfileRepository.swift:11`); `fetchActiveProfile()` returns the one row
  with that id and `createDefaultProfile()` inserts a row with it.
- `ProfileViewModel` is a single long-lived `@Observable` instance created once in `TDEEApp`, threaded
  by binding through the whole UI tree; its load/save are hard-coded to that id.
- The `Profile` entity has **no name/identity field** — its only identity is `id: UUID`.
- The Main profile is identified by `name == "Main"` rather than a fixed UUID.

## Scope

- A **Main** profile: the profile the app opens to for quick daily use.
- **Named profiles** for other people, each a full profile (gender, age, height, weight, activity,
  body fat, goal, selected macro).
- Create, name, switch to, and delete profiles.
- The **macro catalog stays shared** (a `MacroPreset` is a shared catalog, not owned by a profile — this
  predates the story and is preserved): each profile just *selects* one preset via its own
  `selectedMacroId`.
- **iPhone target only.** The watch target is unchanged and out of scope (see Out of Scope).

## Decisions

Confirmed with the owner:

1. **Macros stay shared.** No per-profile macro catalog. A profile for a different person draws from the
   same preset list. Minimal change, matches today's design.
2. **Launch opens the Main profile.** Switching to another person is a per-session action; relaunch
   returns to Main. No "remember last used" persistence is needed.
3. **Identity is name-only.** Each profile gets a `name` (e.g. "Me", "Partner"). No avatar/emoji.
4. **The Main profile cannot be deleted** (also the last remaining profile cannot be deleted), so there
   is always at least one profile.
5. **iPhone only.** No watch changes; phone↔watch sync of the selected profile is a separate, later
   concern.
6. **No migration needed.** The app has not been released yet; device wipe on upgrade is acceptable.

## Screens

- **Profiles list** (new, reached from the System menu): a list of profiles by name, marking the active
  one; an **"Add"** button to create; tap a row to **switch** to it; per-row delete (guarded for Main).
  Mirrors `MacroOptionsListViewPage` + its card/item subviews.
- **Profile editor / create** (new): a `Form` with a **Name** field, Cancel/Save, and a delete
  confirmation. Mirrors `MacroEditViewPage` + `DeleteConfirmationSheet`.
- **Quick switch (new, toolbar)**: a toolbar item on the **leading** side, beside the existing system /
  hamburger menu (`ContentView.swift:61`), listing the profile names. Selecting one switches to that
  profile and recomputes calories and macros for that person, so a switch does not require opening the
  System menu. Placed leading by decision (the Theme button stays trailing, `:69`).
- **System menu** (`UISystemPageView`): a new **"Profiles"** row in the *Navigation* section.

## Not shared / Out of Scope

- **The watch target** — `TDEEWatch` keeps its own single profile; the phone's selected profile does not
  reach the watch. (Tie to the parked phone↔watch sync work; that is a separate story.)
- **Per-profile macro mixes** — presets remain a shared catalog.
- **Avatar / emoji / photo identity** — name only.
- **CloudKit / iCloud sync of profiles** — local SwiftData only, as today.
- **Editing the full field set from the profile editor** — the editor names the profile; field entry
  stays on the existing main-screen sections.

## Acceptance Criteria

- The app opens to the **Main** profile.
- The user can add a new profile, give it a name, and switch to it; the main screen shows that person's
  data and recomputes TDEE and macros for them.
- Switching back returns the first person's data.
- Profiles (names + fields) persist across app launches in SwiftData.
- Relaunching opens the **Main** profile, not the last-used one.
- The **Main** profile (or the only profile) cannot be deleted; a non-Main profile can.
- All existing single-profile and calculation tests still pass; the one-profile persistence invariant
  test is updated to reflect multiple profiles.
- The **watch app is unchanged** in look and behaviour; the full test suite passes.

## Open Questions

- **Resolved:** the quick switch is a leading toolbar item beside the system menu (not top of the scroll,
  not trailing) — see *Screens*.
- Whether a freshly created profile starts from the device/simulator defaults (yes, via
  `SeedData.profileDefaults()`) and whether it is immediately marked `Main`-eligible — settled by
  implementation.

## Status

In Planning — awaiting approval to proceed with implementation (see `plan.md`).
