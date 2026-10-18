# Plan: Story 022 — iPad Adaptation

Present a three-column `NavigationSplitView` on the **regular** horizontal size class (sidebar +
content + detail), while leaving the **compact** (iPhone) experience exactly as it is today. The
model layer is untouched — this is a view-layer/layout story. Deployment target is iOS 26.4/26.5,
so the 3-column `NavigationSplitView` (iOS 16+) is available.

## Decisions (from story.md, Decisions 8–12)

- **Three-column split** on regular; single `NavigationStack` on compact.
- **Sidebar shows the in-session profile list** (grouped, active checked); tapping a profile row
  quick-switches (`profileStore.activate(to:)`), it does not navigate.
- **Detail navigation preserves `AppRoute`** — pushed pages live in a `NavigationStack` inside the
  detail column.
- **Keep the title swap** (`ContentView.swift:56-60`).
- **Let the layout float** — no rotation/resize/Slide Over handling.
- Watch target unchanged; no new persistence.

## The core tension (read first)

Today navigation is **path-based**: `NavigationStack(path: $path)` + a
`.navigationDestination(for: AppRoute.self)` switch (`ContentView.swift:50,105-124`), driven by
`path: [AppRoute]`. A `NavigationSplitView` is **selection-based** (sidebar selection drives the
detail). Decision 11 says preserve `AppRoute`, so the plan keeps the path stack *inside* the detail
column and uses the split only for the top-level sectioning. **The crux is bridging the two**;
get it wrong and the phone path regresses. Phase 6 is a hard regression gate.

## Phase 1 — Size-class container

- **`ContentView.swift`** — read `@Environment(\.horizontalSizeClass)` (already imported at `:35`)
  and branch the root:
  - **compact** → the *current* tree, unchanged (single `NavigationStack` + `.navigationDestination`).
  - **regular** → a `NavigationSplitView(sidebar:content:detail:)`.
- Keep the shared `@State` (`path`, `profile`, `macroCollection`, `profileStore`) and the
  `.task` / `.onChange` / `.sheet` logic — they must run regardless of layout.
- **Extract the inner content** (the `NavigationStack` body) into a helper so both branches share
  it; the compact branch is byte-for-byte the current tree.

## Phase 2 — Sidebar (regular only)

- **New `SidebarView`** — a `List` of destinations mirroring `UISystemPageView`'s *Navigation*
  section (`UISystemPageView.swift:17-30`): **Main**, **Macro Config**, **Profiles**, **Theme**,
  **About**.
  - **Main** = the default detail (the `UIMainView` home); selecting it resets to the main screen.
  - **Profiles** = a grouped section listing `profileStore.profiles` with the active one checked;
    tapping a row calls `profileStore.activate(to:)` (quick switch, no navigation). This is the
    in-session profile list from Decision 8.
  - The **Data** action (Reset Macro Presets, `UISystemPageView.swift:32-37`) stays reachable on
    iPad (a sidebar section, or surfaced via the detail).
- Sidebar selection sets which section shows in content/detail.

## Phase 3 — Content + detail columns

- **Detail column** = `UIMainView` as the landing/home, plus a `NavigationStack(path:)` that owns
  the `.navigationDestination(for: AppRoute.self)` switch — so `AppRoute` and every pushed route
  keep working (Decision 11).
- **Content column** = the list pages: macro options list (`MacroOptionsListViewPage`) and profile
  list (`ProfileListViewPage`). Selecting an item in content drives the detail (editor).
- Reconcile `path` (path-based) with sidebar selection (selection-based): the simplest bridge is to
  let the sidebar pick the *section* and keep `path` for sub-navigation within a section. Exact
  mapping is settled in implementation; keep `AppRoute` as the source of truth.

## Phase 4 — Move quick-switch + theme to the detail toolbar

- On regular, the profile quick-switch `Menu` (`ContentView.swift:64-82`) and the theme button
  (`:91-98`) render in the **detail** column's toolbar (they act on the active screen), not the
  sidebar. On compact they stay as today.

## Phase 5 — Main column width

- Extend the `UIMainView` `GeometryReader` padding (`UIMainView.swift:57-67`, currently only
  `padding(.horizontal, width <= 375 ? 0 : 16)`) so content is **capped to a comfortable column
  width and centered** on regular, rather than stretching full-width.

## Phase 6 — Compact regression gate (hard)

- iPhone / compact must be **identical to today**: hamburger menu (`:83-90`) + pushed pages, same
  title swap (`:56-60`). Verify by running compact in the simulator before calling the story done.
- Watch target untouched — confirm the watch scheme still builds and its screens are unchanged.

## Phase 7 — Tests

- No model changes, so the existing suite (profile, calculation, theme, share, SwiftData) must pass
  unchanged.
- Layout is hard to unit-test in this repo; verify iPad vs iPhone **manually** in simulators.
- Follow the `implement-story` skill: run `xcodebuild -project TDEE.xcodeproj -scheme TDEE
  -configuration Debug test` after implementation.

## Files to create

```
TDEE/Pages/Sidebar/SidebarView.swift   (regular-only sidebar; profile quick-switch section)
```

## Files to modify

| File | Change |
|------|--------|
| `TDEE/ContentView.swift` | Size-class branch: `NavigationSplitView` on regular, current `NavigationStack` on compact; extract shared content; move quick-switch + theme to detail toolbar (Decision 10 keeps the title swap) |
| `TDEE/Pages/MainPage/UIMainView.swift` | Cap + center the main column on regular (extend `:57-67`) |
| `TDEE/Pages/SystemPage/UISystemPageView.swift` | Reuse the Navigation/Data items as the sidebar's source; ensure Reset stays reachable on iPad |
| `TDEE/Pages/MacroOptionsListViewPage/MacroOptionsListViewPage.swift` | Present in the content column on regular |
| `TDEE/Pages/ProfileListPage/ProfileListViewPage.swift` | Present in the content column on regular |

## Testing checklist

- [ ] iPhone (compact): hamburger + pushed pages, identical to today; title swap intact
- [ ] iPad (regular): three-column split — sidebar + content + detail
- [ ] Sidebar shows the in-session profile list; tapping a row quick-switches (no navigation)
- [ ] Every destination (main, macro config + editor, profile list + editor, theme, about) presents
      well on iPad — no stretched/unbalanced sections; sensible column width
- [ ] Quick-switch + theme reachable on the detail toolbar; Reset Macro Presets reachable on iPad
- [ ] Existing tests pass (no model changes); watch app unchanged

## Risks

- **Bridging path-based `AppRoute` to selection-based `NavigationSplitView`** — the main risk; a
  bad bridge regresses phone navigation or leaves a route unreachable on iPad. Phase 6 gates it.
- **Compact regression** — the size-class branch must fall through to the exact current tree on
  compact; extract shared content so there is a single source of truth, not two copies to drift.
- **Column-mapping churn** — which page lives in content vs detail may need iteration; keep
  `AppRoute` authoritative and the mapping explicit.
- **Layout is hard to automate** — rely on manual iPad/iPhone simulator checks; the automated suite
  only guards the model layer.
