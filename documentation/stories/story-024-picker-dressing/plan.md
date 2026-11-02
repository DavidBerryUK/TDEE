# Plan: Story 024 — Picker Dressing

Build the model-layer `PickerDressing` so a theme *adopts* a picker dressing instead of hand-tuning
seven loose `ColorPalette` fields, **with the picker views frozen**. See `story.md` for the decisions;
this file is the build.

> **Status: built (2026-11-02).** Decisions 1–5 are locked and implemented; `PickerDressingTests`
> pass (7/7); the stale `testAllThemes` is fixed. Only the pre-existing marginal `testContrast` case
> remains (out of scope).

## The core tension

The seven picker fields are a **max union** across five controls, but each control consumes a different
subset and four are **inert for Orange** (the only theme that sets them — see `story.md`, *Finding*).
So the generalisation is **one adopted value** the model owns and `ColorPalette`'s init *expands into*
the seven stored fields the frozen views still read — not seven new knobs, and no view change.

## Steps

1. **`PickerDressing` (new file, `TDEE/Models/Theme/`)** — a value bundling the seven fields, all
   `nil`-default:
   - `.plain` static → all `nil` (undressed native wheel; the `ColorPalette` default).
   - `.orange` static → the exact seven values (`background` = `#F8D0C5` light-coral, `colorScheme`
     = `.light`, `panelWidth` 96, `labelOffsetX` 78, `feetLabelOffsetX` 74,
     `feetInchesLabelOffsetX` 82, `wheelSpacing` 60). `lightCoral` moves here from `DefaultThemes`.
   - `.panel(background:appearance:width:)` factory → sets only the panel fields, offsets left `nil`
     (inert in the caption-beside layout a panel triggers).
   - `isThemed` predicate = `background != nil || colorScheme != nil`, mirroring
     `ColorPalette.isPickerThemed`.
2. **`ColorPalette` (`Theme.swift`)** — replace the seven picker init params with one
   `pickerDressing: PickerDressing? = nil`; expand it (`nil` → `.plain`) into the seven **stored**
   fields. The stored fields and `isPickerThemed` are unchanged, so the frozen views compile as-is.
3. **`DefaultThemes`** — `orange` adopts `pickerDressing: .orange` (its seven numbers collapse into the
   preset; remove the now-unused `lightCoral`). The ten plain themes pass nothing (default `nil`).
4. **Fix the stale test** — `DefaultThemesTests.testAllThemes`: `ids.count == 10` → `11` (+ the test
   name), since `ThemeID` / `DefaultThemes.all` hold 11 themes.
5. **`PickerDressingTests` (new file, `TDEETests/`)** — 7 regression cases: `.plain` all-`nil`;
   `.orange` reproduces the exact seven (via a `hex(_:)` helper, `Color` isn't `Equatable`);
   `.panel(…)` sets only the panel fields; `ColorPalette(pickerDressing:)` expansion; no dressing →
   `nil`; Orange adopts the dressing; every non-Orange theme stays undressed.

## Verification

Per `.claude/skills/compile.md`, on **iPhone 17 Pro Max / iOS 27.0**:
`xcrun xcodebuild -project TDEE.xcodeproj -scheme TDEE -configuration Debug -destination
'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0' test`.

- App builds; the 7 new cases pass; **zero new failures**.
- The two remaining suite failures (`testAllThemes`, one `testContrast` case) are **pre-existing on
  `features/themes`** — proven by re-running the clean baseline with this work `git stash`ed.
  `testAllThemes` is fixed by step 4; the `testContrast` case is left (out of scope, Decision 5).

## Frozen (do not touch)

`UIWheel*Plain`, `UIWheel*Themed`, `UIThemedWheelPicker`, the `pickerPanel` modifier
(`Color+Theme.swift`), the 8 `isPickerThemed` sites, `UITextPickerLabel`, `UILayoutSectionView`,
`ThemeCardView`, `ThemeView`, `WatchPalette`.
