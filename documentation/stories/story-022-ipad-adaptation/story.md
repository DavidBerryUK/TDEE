# Story 022: iPad Adaptation

**Objective:** Make the iPhone-first UI feel native on iPad by presenting a persistent
navigation **sidebar** with the main screen as **detail** on the *regular* horizontal size
class, while leaving the *compact* (iPhone) experience exactly as it is today.

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

1. **Split view on regular.** Use `NavigationSplitView` on the regular size class: a persistent
   navigation **sidebar** + the **main screen as detail**.
2. **All screens in scope.** Main + System/Theme/Macro list & editor/Profile list & editor/About
   all adapt — one coherent pass, not a main-only first step.
3. **Compact unchanged.** On compact, keep the current `NavigationStack` + hamburger menu; no
   phone regression.
4. **Sidebar mirrors the System menu.** The sidebar's destinations match the *Navigation* section
   of `UISystemPageView` (Macro Config, Profiles, Theme, About); the main screen is the default
   detail. The *Data* action (Reset Macro Presets) stays reachable on iPad too.
5. **Quick-switch and theme move to the detail toolbar.** The profile quick-switch `Menu`
   (`ContentView.swift:64-82`) and the theme button (`:91-98`) act on the active screen, so on
   regular they live in the detail column's toolbar.
6. **Watch target unchanged** — out of scope (see Out of Scope).
7. **No new persistence.** Any layout/UI state is session-only; no new SwiftData entities.
8. **Sidebar shows the in-session profile list.** *Profiles* is a grouped sidebar section listing the
   current profiles with the active one checked — not a single row that opens a separate list.
9. **Three-column split.** `NavigationSplitView` as sidebar + content + detail, so the list→editor
   flows (macro, profile) use the middle content column.
10. **Keep the title swap.** The compact/regular navigation-title swap (`ContentView.swift:56-60`)
    is kept; the split layout does not supersede it.
11. **Detail navigation preserves `AppRoute`.** Pushed pages live in a `NavigationStack` inside the
    detail column, so `AppRoute` and all existing routes keep working.
12. **Let the layout float (for now).** No rotation/resize/Slide Over handling in this story; the
    layout floats to the window. To be revisited after seeing it work in practice.

## Screens / Layout

- **Sidebar (regular):** a `List` of destinations; selecting one sets the detail, with the active
  destination highlighted.
- **Detail (regular):** the main screen (`UIMainView`) is the landing detail. Pushed pages
  (editors, list→editor flows) push within a `NavigationStack` inside the detail column so the
  existing `AppRoute` navigation keeps working.
- **Main column width:** even inside the detail, constrain the main screen's content to a
  comfortable column width and center it — extend the existing `GeometryReader` padding logic in
  `UIMainView.swift:57-67` rather than stretching full-width.
- **Compact:** unchanged — hamburger + pushed pages, identical to today.

## Not shared / Out of Scope

- **The watch target** — `TDEEWatch` keeps its own layout; unchanged.
- **Mac / visionOS** — only the iPhone + iPad device families.
- **Orientation / rotation / landscape-specific layouts** — open question, not decided here.
- **Window resizing / Slide Over** behaviour at narrow regular widths — open question.
- **iCloud / CloudKit sync** — none.
- **Model-layer changes** — no new entities or persisted layout.
- **Profile↔watch sync** — still parked (story-021); a separate concern.

## Acceptance Criteria

- On iPad (regular size class) the app shows a **persistent navigation sidebar** with the main
  screen as detail; selecting a destination swaps the detail.
- **Every destination** (main, macro config + editor, profile list + editor, theme, about)
  presents well on iPad — no stretched/unbalanced sections; a sensible column width.
- **Compact is unchanged** — iPhone keeps the hamburger menu + pushed pages, identical to today.
- The **quick-switch profile menu** and **theme button** remain reachable on iPad (moved to the
  detail toolbar).
- **Reset Macro Presets** remains reachable on iPad.
- The full test suite passes with no regressions in the shared/model layer.
- The **watch app is unchanged** in look and behaviour.

## Open Questions

All resolved (see Decisions 8–12).

## Status

Planned — all open questions resolved (Decisions 8–12); implementation plan in `plan.md`, feature
branch `features/story-022-ipad-adaptation` created. Ready for implementation.
