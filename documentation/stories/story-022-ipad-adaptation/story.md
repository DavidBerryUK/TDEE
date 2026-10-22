# Story 022: iPad Adaptation

**Objective:** Make the iPhone-first UI feel native on iPad by presenting a two-column
**master + detail** split on the *regular* horizontal size class: a drill-down navigation
**master** (left) and the main screen as **detail** (right), while leaving the *compact*
(iPhone) experience exactly as it is today.

## Background

The phone target already runs on iPad — `TARGETED_DEVICE_FAMILY = "1,2"` in
`TDEE.xcodeproj/project.pbxproj` (the iPhone build configs) — but the UI was designed for a
single narrow column and has not been adapted:

- **Only size-class-aware code today is a title swap.** `ContentView.swift:56-60` picks the
  navigation title (`"TDEE"` on compact, `"Total Daily Energy Expenditure"` on regular) from
  `@Environment(\.horizontalSizeClass)`. Nothing else branches on size class.
- **The main screen is a full-width single column.** `UIMainView.mainContent`
  (`UIMainView.swift:57-67`) is a `GeometryReader` + `ScrollView`; it only adds horizontal
  padding when `geometry.size.width > 375` (`:63`), so on iPad the one column of sections
  stretches across the whole screen and looks unbalanced.
- **Navigation is push-based.** A hamburger `ToolbarItem(.topBarLeading)`
  (`ContentView.swift:83-90`) appends `.system`; `UISystemPageView`
  (`UISystemPageView.swift:15-39`) is a `List` with a *Navigation* section (Maintain Macro
  Config, Profiles, Theme, About) and a *Data* section (Reset Macro Presets). The tree is a
  `NavigationStack(path: $path)` with a `.navigationDestination(for: AppRoute.self)` switch
  (`ContentView.swift:50,105-124`).
- **`AppRoute`** (`AppRoute.swift:9-18`): `system`, `maintainMacroConfig`, `theme`, `about`,
  `macroEditorCreate`, `macroEditorEdit(_)`, `profiles`, `profileEditor(item:)`.

## Scope

- Adapt to the **regular** horizontal size class (iPad, and iPad in any regular-width window):
  every app destination — main, macro config + editor, profile list + editor, theme, about —
  presents well.
- The **compact** size class (iPhone, and any narrow/compact window) is **unchanged**: the
  existing `NavigationStack` + hamburger menu stays.
- **Preserve the model layer.** No change to `ProfileViewModel`, `ProfileStore`,
  `MacroSplitOptionsModelCollection`, environment injection, or the single shared
  `ProfileViewModel` — this is a view-layer/layout concern.

## Decisions

Confirmed with the owner:

1. **Split view on regular.** Use `NavigationSplitView` on the regular size class as a
   **two-column master + detail** (no middle content column).
2. **All screens in scope.** Main + System/Theme/Macro list & editor/Profile list & editor/About
   all adapt — one coherent pass, not a main-only first step.
3. **Compact unchanged.** On compact, keep the current `NavigationStack` + hamburger menu; no
   phone regression.
4. **Master mirrors the System menu, as a drill-down.** The master (left) is a `NavigationStack`
   whose top level matches the *Navigation* section of `UISystemPageView` — **Main, Macro Config,
   Profiles, Theme, About**. Tapping an item pushes that screen onto the master with a back arrow
   to return; **Main** pops back to the menu. The *Data* action (Reset Macro Presets) is a master
   section, so it stays reachable on iPad.
5. **Quick-switch and theme stay on the detail toolbar.** The profile quick-switch `Menu`
   (`ContentView.swift:64-82`) and the theme button (`:91-98`) act on the active screen, so on
   regular they live in the detail column's toolbar. With Profiles + Theme now also reachable in the
   master, these are redundant but kept for quick access.
6. **Watch target unchanged** — out of scope (see Out of Scope).
7. **No new persistence.** Any layout/UI state is session-only; no new SwiftData entities.
8. **Profiles is a drill-down sub-screen.** Tapping *Profiles* in the master pushes
   `ProfileListViewPage` — the in-session profile list, active one checked — onto the master;
   tapping a row quick-switches (`profileStore.activate(to:)`), it does not navigate.
9. **Two-column drill-down.** `NavigationSplitView` as **master + detail** (no middle content
   column). The macro / profile lists live in the master as drill-down sub-screens; their add/edit
   opens in the **detail** via the shared `path`, so an editor slides into the detail on top of the
   main screen while the list stays in the master.
10. **Keep the title swap.** The compact/regular navigation-title swap (`ContentView.swift:56-60`)
    is kept; the split layout does not supersede it.
11. **Detail navigation preserves `AppRoute`.** Pushed pages live in a `NavigationStack` inside the
    detail column, so `AppRoute` and all existing routes keep working.
12. **Let the layout float (for now).** No rotation/resize/Slide Over handling in this story; the
    layout floats to the window.
13. **Theme sub-screen keeps its card grid.** The master's *Theme* screen reuses `ThemeView` (the
    existing wide card grid) rather than a compact row layout; accepted as-is for the narrow master
    column.
14. **Main screen stays the detail's home.** The detail always shows `UIMainView` as its home;
    editors push on top of it. Theme / About / Profiles / Macros are *not* in the detail — they
    live in the master — so the detail no longer switches on a top-level selection.

## Screens / Layout

- **Master (regular):** a `NavigationStack` whose root is a menu — **Main, Macro Config, Profiles,
  Theme, About** (plus a *Data* section with Reset Macro Presets). Tapping an item pushes its
  screen onto the master; a back arrow (or **Main**) returns to the menu. The macro / profile lists
  and the theme card grid render *here*.
- **Detail (regular):** the main screen (`UIMainView`) is the landing detail and stays as its home.
  Editors (macro/profile add/edit, theme, about) push within a `NavigationStack` inside the detail
  column so the existing `AppRoute` navigation keeps working.
- **Editor flow:** tapping a macro/profile row or "Add" in the master's list slides the editor into
  the detail (the list pages take the detail's `path`); the list stays in the master.
- **Main column width:** capping + centering the main screen's content on regular is done —
  `UIMainView.mainContent` caps the column at 560pt and centres it on wide screens
  (`.frame(maxWidth: 560)` + `.frame(maxWidth: .infinity)`, `UIMainView.swift:62-63`).
- **Compact:** unchanged — hamburger + pushed pages, identical to today.

## Not shared / Out of Scope

- **The watch target** — `TDEEWatch` keeps its own layout; unchanged.
- **Mac / visionOS** — only the iPhone + iPad device families.
- **iCloud / CloudKit sync** — none.
- **Model-layer changes** — no new entities or persisted layout.
- **Profile↔watch sync** — still parked (story-021); a separate concern.

## Acceptance Criteria

- On iPad (regular size class) the app shows a **two-column master + detail**: a drill-down
  navigation master on the left, the main screen as detail on the right; selecting a master item
  pushes its screen, and editing an item opens in the detail.
- **Every destination** (main, macro config + editor, profile list + editor, theme, about)
  presents well on iPad — no stretched/unbalanced sections; a sensible column width.
- **Compact is unchanged** — iPhone keeps the hamburger menu + pushed pages, identical to today.
- The **quick-switch profile menu** and **theme button** remain reachable on iPad (detail toolbar).
- **Reset Macro Presets** remains reachable on iPad (master *Data* section).
- The full test suite passes with no regressions in the shared/model layer.
- The **watch app is unchanged** in look and behaviour.

## Status

Done. The two-column drill-down master + detail is implemented per Decisions 1–14 (merged 2026-10-19,
`features/story-022-ipad-adaptation`); `TDEE` and `TDEEWatch` build and the full test suite passes.

- **Main-column capping** — done in code: `UIMainView.mainContent` caps the column at 560pt and
  centres it on wide screens (`.frame(maxWidth: 560)` + `.frame(maxWidth: .infinity)`,
  `UIMainView.swift:62-63`), closing the previously-open follow-up.
- **Remaining manual gate** — visual confirmation in the iPad and iPhone simulators is the owner's
  check; layout is not unit-tested, so the automated suite guards the model layer only.
