# Plan: Story 022 — iPad Adaptation

Present a **two-column** `NavigationSplitView` on the **regular** horizontal size class (a
drill-down **master** on the left, the main screen as **detail** on the right), while leaving the
**compact** (iPhone) experience exactly as it is today. The model layer is untouched — this is a
view-layer/layout story. Deployment target is iOS 26.4/26.5.

> **Design correction (2026-10-18).** The original plan called for a *three-column*
> `NavigationSplitView(sidebar:content:detail:)` with the lists in a middle content column. The
> owner found that wrong: the intended shape is a **two-column** master + detail where the macro /
> profile **lists live in the master as drill-down sub-screens** and editors open **in the detail**.
> This plan now describes the two-column drill-down design as implemented.

## Decisions (from story.md, Decisions 1–14)

- **Two-column drill-down** on regular; single `NavigationStack` on compact. No middle content column.
- **Master** is a `NavigationStack` rooted at a menu (Main, Macro Config, Profiles, Theme, About) +
  a *Data* section (Reset Macro Presets); tapping an item pushes its screen with a back arrow,
  **Main** pops to the menu.
- **Profiles** sub-screen = `ProfileListViewPage` (in-session list, active checked); a row tap
  quick-switches (`profileStore.activate(to:)`), it does not navigate.
- **Theme** sub-screen reuses `ThemeView` (card grid, unchanged).
- **Editor flow:** add/edit from a master list slides the editor **into the detail** (the list
  pages take the detail's `path`); the list stays in the master.
- **Detail** always shows `UIMainView` as its home; editors push on top. Detail no longer switches
  on a top-level selection (theme/about/profiles/macros are in the master, not the detail).
- **Detail navigation preserves `AppRoute`** — pushed pages live in a `NavigationStack` inside the
  detail column.
- **Detail toolbar kept:** quick-switch `Menu` + theme button (redundant now, harmless).
- **Keep the title swap** (`ContentView.swift:56-60`).
- **Let the layout float** — no rotation/resize/Slide Over handling.
- Watch target unchanged; no new persistence.
- **Open:** main-column width capping (`UIMainView`) — not part of this pass.

## The core tension (read first)

Today navigation is **path-based**: `NavigationStack(path: $path)` + a
`.navigationDestination(for: AppRoute.self)` switch, driven by `path: [AppRoute]`. The two-column
split bridges this cleanly:

- The **master** owns its *own* `NavigationStack` with its own path (`masterPath: [MasterDestination]`)
  for the menu → sub-screen drill-down.
- The **detail** keeps the app's `path`-based `NavigationStack` + `AppRoute` `navigationDestination`.
- The list pages in the master (`MacroOptionsListViewPage`, `ProfileListViewPage`) take the
  **detail's** `$path`, so their add/edit appends to the *detail* stack — the editor appears in the
  detail while the list stays in the master.

Because the bridge is "master has its own stack, detail keeps `AppRoute`, lists borrow the detail's
path", a bad bridge would regress phone navigation or leave a route unreachable on iPad. **Phase 6
is the hard regression gate.**

## As implemented

### Size-class container
- **`ContentView.swift`** branches the root on `@Environment(\.horizontalSizeClass)`:
  - **compact** → the *current* tree, unchanged (single `NavigationStack` + `.navigationDestination`
    + hamburger). `compactLayout` is byte-for-byte the pre-story tree.
  - **regular** → `NavigationSplitView { SidebarView(path: $path, selectedMacroId: $profile.selectedMacroId) }
    detail: { NavigationStack(path: $path) { mainDetail … } }` — **no `content` closure**.
- Shared `@State` (`path`, `profile`, `macroCollection`, `profileStore`) and the `.task` / `.onChange`
  / `.sheet` logic run regardless of layout. `contentColumn`, `detailRoot`, `sidebarSelection` and its
  `.onChange` were removed.

### Master (`SidebarView`, regular only)
- `TDEE/Pages/Sidebar/SidebarView.swift` is a `NavigationStack(path: $masterPath)` rooted at `menuRoot`.
- `menuRoot` = a `List`:
  - **Navigate** section: **Main** (a `Button` that pops `masterPath = []`), plus `NavigationLink`s
    into `.profiles`, `.macros`, `.theme`, `.about`. Values are fully qualified
    (`NavigationLink(value: MasterDestination.profiles)`) — SwiftUI does not infer the value type
    across the `navigationDestination` scope.
  - **Data** section: a *Reset Macro Presets to Defaults* destructive button + `confirmationDialog`,
    mirroring `UISystemPageView` (`@Environment(MacroSplitOptionsModelCollection.self)`,
    `resetToDefaults()`).
- `.navigationDestination(for: MasterDestination.self)`:
  - `.profiles` → `ProfileListViewPage(path: $path)`
  - `.macros`   → `MacroOptionsListViewPage(path: $path, selectedMacroId: $selectedMacroId)`
  - `.theme`    → `ThemeView()`
  - `.about`    → `AboutPage()`
- New `MasterDestination` enum (`profiles / macros / theme / about`) replaces the old `SidebarDestination`.
  `SidebarView` takes `path: [AppRoute]` + `selectedMacroId: UUID` and owns `masterPath`.

### Detail
- The detail's `NavigationStack(path: $path)` home is `mainDetail` (`UIMainView`), with the
  quick-switch + theme toolbar and the `.navigationDestination(for: AppRoute.self)` switch unchanged.
  Editors (macro/profile add/edit, theme, about) push on top of the main screen.

### Main column width (open)
- **Not done in this pass.** `UIMainView.mainContent` (`UIMainView.swift:57-67`) still only pads
  when `width > 375`; capping + centering the main screen on regular is a separate follow-up.

### Compact regression gate (hard)
- `compactLayout` is the exact pre-story tree: hamburger menu + pushed pages, same title swap.
  Verified by building; visual confirmation in the iPhone simulator is the manual gate.

### Tests
- No model changes, so the existing suite (profile, calculation, theme, share, SwiftData) passes
  unchanged (verified: `TEST SUCCEEDED`).
- Layout is hard to unit-test; iPad vs iPhone is verified **manually** in simulators.
- Run: `xcodebuild -project TDEE.xcodeproj -scheme TDEE -configuration Debug test`.

## Files

| File | Change |
|------|--------|
| `TDEE/Pages/Sidebar/SidebarView.swift` | **Rewrote** as a drill-down `NavigationStack` master; new `MasterDestination`; Navigate + Data sections; sub-screens via `.navigationDestination`. |
| `TDEE/ContentView.swift` | `regularLayout` → two-column master + detail; removed `contentColumn`, `detailRoot`, `sidebarSelection`, its `.onChange`; detail home is `mainDetail`. `compactLayout` / `routeDestination` / `mainDetail` unchanged. |
| `TDEE/Pages/MainPage/UIMainView.swift` | **Open** — cap + center the main column on regular (not done yet). |

Reused as-is: `ProfileListViewPage`, `MacroOptionsListViewPage`, `MacroOptionsListCardView`,
`ThemeView`, `AboutPage`, `routeDestination`, `quickSwitchMenu`.

## Testing checklist

- [x] `TDEE` + `TDEEWatch` build; full test suite passes (`TEST SUCCEEDED`)
- [ ] iPhone (compact): hamburger + pushed pages, identical to today; title swap intact — **manual**
- [ ] iPad (regular): two-column split — master + detail; no middle column — **manual**
- [ ] Master drill-down: Profiles / Macros / Theme / About push onto the master with a back arrow;
      **Main** returns to the menu — **manual**
- [ ] Editing a macro/profile from the master's list opens the editor **in the detail** — **manual**
- [ ] Theme sub-screen shows the card grid; Reset Macro Presets reachable on iPad — **manual**
- [ ] Every destination presents well on iPad; main-column width capping still open — **manual**

## Risks

- **Bridging path-based `AppRoute` to the two-column split** — the master owns its own stack and the
  detail keeps `AppRoute`; a bad bridge regresses phone navigation or leaves a route unreachable on
  iPad. Phase 6 / the compact gate handles it.
- **Compact regression** — the size-class branch must fall through to the exact current tree on
  compact; `compactLayout` is the single source of truth.
- **Layout is hard to automate** — rely on manual iPad/iPhone simulator checks; the automated suite
  only guards the model layer.
