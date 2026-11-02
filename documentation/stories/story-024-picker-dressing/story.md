# Story 024: Picker Dressing

**Objective:** Generalise *how a theme dresses its wheel pickers* from an Orange-only special case
into a reusable, model-layer concept — a `PickerDressing` a theme **adopts** — so that any theme (or a
future one) can opt in with one call, **without touching the picker views.**

## Background

Story 023 split every wheel into a **Plain** sibling (the original native `.pickerStyle(.wheel)`) and a
**Themed** sibling (a `UIPickerView` a theme can dress). A theme opts into the Themed path via
`ColorPalette.isPickerThemed` (`pickerBackground != nil || pickerColorScheme != nil`), which the 8
call sites (5 section editors + 3 New-section views) branch on.

The picker's dressing lived as **seven loose optional fields on `ColorPalette`**:
`pickerBackground`, `pickerColorScheme`, `pickerPanelWidth`, `pickerLabelOffsetX`,
`pickerFeetLabelOffsetX`, `pickerFeetInchesLabelOffsetX`, `pickerWheelSpacing`. **Only Orange set any
of them**; the other ten themes left all seven `nil`. So the elaborate themed stack (the 5
`UIWheel*Themed` wrappers, `UIThemedWheelPicker`, the `pickerPanel` modifier) was generalised
machinery serving **a single consumer**, and Orange hand-tuned seven magic numbers scattered through its
`ColorPalette` initializer.

### Finding: which of the seven are even live for Orange

`UITextPickerLabel` reads only `palette.textSecondary` (it applies **no** offset), and in the Themed
(caption-beside) layout the unit caption sits to the *right* of the wheel in an `HStack`, so:

| Field | Live for Orange? | Consumed by |
|---|---|---|
| `pickerBackground` | ✅ | all 5 themed wheels (`.pickerPanel`) |
| `pickerColorScheme` | ✅ | all 5 (forced appearance + `UIThemedWheelPicker`) |
| `pickerPanelWidth` | ✅ Height / Weight | their `.pickerPanel(width:)` (Age/BodyFat/Activity hardcode 160/110/220) |
| `pickerLabelOffsetX` / `pickerFeetLabelOffsetX` / `pickerFeetInchesLabelOffsetX` / `pickerWheelSpacing` | ⛔ **inert** | only the *plain* caption-over branch; Orange takes caption-beside |

Four of the seven fields are **inert for Orange** but are preserved (not "fixed" — see
`[[age-inert-under-katch-mc-ardle]]` philosophy) so `.orange` reproduces exactly what the theme passes
today and a future layout change would pick them up.

`ColorPalette` is constructed **only in `DefaultThemes.swift`** (the watch uses the separate
`WatchPalette`), so changing the palette's init is contained; and the seven fields stay **stored on
`ColorPalette`**, which the frozen picker views read by name — so the views need not change.

## Decisions

Confirmed with the owner:

1. **Models/data only, views frozen.** The picker's layout is "very sensitive to change"; the
   generalisation must live in the model layer. `UIWheel*Plain`, `UIWheel*Themed`,
   `UIThemedWheelPicker`, the `pickerPanel` modifier (`Color+Theme.swift`), and the 8 `isPickerThemed`
   sites stay **byte-for-byte**. `isPickerThemed` keeps its current derivation.
2. **Shape: minimal + a generic factory.** A `PickerDressing` value bundles the seven fields with
   `.plain` (all `nil`), `.orange` (the exact current values — the new single source of truth), and a
   `.panel(background:appearance:width:)` factory so any future theme opts in with one call. (A
   `.preset library` was considered and set aside — most general, but the un-tuned looks risk a later
   regression.)
3. **Mechanism only.** No plain theme actually opts in yet; all ten stay undressed, and Orange is
   pixel-identical. The `.panel(…)` factory is available for a future theme, not exercised now.
4. **Out of scope: the non-picker overrides.** `toolbar`, `iconColors`, and `expandedContentBackground`
   are already cleanly general (each `nil`-default, independently adoptable, no Orange side-effect);
   this story is purely about the picker dressing.
5. **The stale test is fixed on this branch.** `DefaultThemesTests.testAllThemes` asserted
   `ids.count == 10` while `DefaultThemes.all` / `ThemeID` hold **11** themes; corrected to `11` (and
   the test name). The one marginal `testContrast` case is **left** — it uses the base color roles
   (`text`/`surface`/`macros`), not the picker fields, and its fix is a design call, out of scope here.

## The core tension (read first)

The "seven fields" are a **max union** across the five controls, but each control consumes a different
subset, and four are inert for the only theme that sets them. The generalisation is therefore **not**
"seven configurable knobs" — it is **one adopted value** (a dressing) that the theme model owns and the
`ColorPalette` init *expands into* the seven stored fields the views still read. That keeps the
generalisation entirely in the model and the frozen views untouched, while collapsing Orange's scattered
magic numbers into a named preset.

## Design

- **`PickerDressing`** (new, `TDEE/Models/Theme/PickerDressing.swift`): a value with the seven fields
  (all `nil`-default), a `.plain` static (undressed), a `.orange` static (the exact seven values;
  `lightCoral = #F8D0C5` moves here from `DefaultThemes`), a `.panel(background:appearance:width:)`
  factory, and an `isThemed` predicate mirroring `ColorPalette.isPickerThemed`.
- **`ColorPalette`** (`Theme.swift`): the init takes one `pickerDressing: PickerDressing? = nil`
  instead of the seven loose fields; it expands the adopted dressing (`nil` → `.plain`) into the seven
  **stored** fields. The stored fields and `isPickerThemed` are unchanged, so the views compile and
  render as before.
- **`DefaultThemes`**: `orange` adopts `pickerDressing: .orange` (its seven numbers collapse into the
  preset; `lightCoral` is removed from the initializer). The ten plain themes pass nothing (default
  `nil` = undressed).

## Files

**Changed (model/data only):**
- `TDEE/Models/Theme/PickerDressing.swift` — **new**: the dressing type + presets + factory.
- `TDEE/Models/Theme/Theme.swift` — `ColorPalette` init: seven picker fields → one `pickerDressing:`.
- `TDEE/Models/Theme/DefaultThemes.swift` — Orange adopts `.orange`; `lightCoral` removed.
- `TDEETests/ThemeTests.swift` — `testAllThemes` count `10` → `11` (+ test name).

**New:**
- `TDEETests/PickerDressingTests.swift` — 7 regression cases.

**Frozen (untouched):** `UIWheel*Plain`, `UIWheel*Themed`, `UIThemedWheelPicker`,
`pickerPanel` / `Color+Theme.swift`, the 8 `isPickerThemed` sites, `UITextPickerLabel`,
`UILayoutSectionView`, `ThemeCardView`, `ThemeView`, `WatchPalette`.

## Testing

`TDEETests/PickerDressingTests.swift` (Swift Testing), 7 cases, all passing:
- `.plain` is all-`nil` / not themed; `.orange` reproduces the exact seven values (via a `hex(_:)`
  helper, since `Color` isn't `Equatable`); the `.panel(…)` factory sets only the panel fields and
  leaves the offsets `nil`.
- `ColorPalette(pickerDressing:)` expands a dressing into its seven stored fields; no dressing leaves
  them `nil`.
- `DefaultThemes.orange` adopts the dressing; **every non-Orange theme stays undressed** (the "plain
  claim").

Build + suite run on **iPhone 17 Pro Max / iOS 27.0** via `.claude/skills/compile.md`
(`xcrun xcodebuild … test -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0'`).
App builds; the 7 new cases pass; **zero new failures** — the two remaining failures
(`testAllThemes`, one `testContrast` case) are **pre-existing on `features/themes`** (verified by
re-running the clean baseline with this work stashed). `testAllThemes` is fixed by Decision 5; the
`testContrast` case is left as a separate, out-of-scope design call.

## Not shared / Out of Scope

- **The picker views** — frozen by Decision 1.
- **The non-picker overrides** (`toolbar`/`iconColors`/`expandedContentBackground`) — already general;
  Decision 4.
- **Actually dressing a plain theme** — mechanism only; no theme opts in yet (Decision 3).
- **The watch** — `WatchPalette` is a fixed palette and never reads the theme (unchanged).
- **The one marginal `testContrast` case** — left for a separate design pass (Decision 5).

## Status

- **Done (2026-11-02).** `PickerDressing` + the `ColorPalette(pickerDressing:)` expansion + the Orange
  adoption are built and tested (7/7 pass); the stale `testAllThemes` count is fixed (`10` → `11`).
  The app builds and the affected suites are green; the full suite shows only the one **pre-existing,
  out-of-scope** marginal `testContrast` case (left per Decision 5).
