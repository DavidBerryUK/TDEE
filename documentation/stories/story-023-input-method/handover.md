# Handover — Story 023 (Input Method): per-input Classic/New toggle rollout

**For a fresh agent.** This document is self-contained: read it, then the canonical docs it points
to, and you can continue the rollout. Do **not** rely on any conversation history.

- **Date:** 2026-10-20
- **Branch:** `feat/height-new-section` (name is now stale — it carries Gender/Age/Weight/Height/Activity
  Level; rename before a PR)
- **Project:** TDEE (iOS). Watch target (`TDEEWatch`) is **out of scope**.

---

## 1. Where to look first (canonical docs)

| File | What it is |
|------|-----------|
| `story.md` (this folder) | **Source of truth.** The Inputs table (the rollout tracker + per-input status), the Decisions, Tasks, Open Questions, Status log. |
| `plan.md` (this folder) | Per-pass implementation plans. Each input's pass has a section (Weight, Height, Activity Level) with Decisions / Files / Testing checklist. |
| `handover.md` (this file) | You are here — current state + how to do the next pass + gotchas. |

When you finish a pass, **update `story.md` and `plan.md`** (see §5) and commit.

---

## 2. Current state

Every main-input section can be presented **Classic** (today's control) or **New** (its redesign),
chosen per input via a persisted toggle. Inputs are rolled out **one at a time**, in the owner's
chosen order.

| # | Input | Model field | Status |
|---|-------|-------------|--------|
| 1 | Gender | `gender` | **Done** |
| 2 | Age | `age` | **Done** |
| 3 | Weight UOM | `weightUom` | **Done** |
| 4 | Weight | `weight` | **Done** |
| 5 | Height UOM | `heightUom` | **Done** |
| 6 | Height | `height` | **Done** |
| 7 | Body Fat % | `bodyFatPercentage` | **Done** |
| 8 | Body Fat Calc Method | `bodyFatPercentageMethod` | **Done** |
| 9 | Activity Level | `activityLevel` | **Done** |
| 10 | Calorie Adjustment Method | `calorieAdjustmentMethod` | Not started |
| 11 | Calorie Adjustment Value | (slider) | Not started |
| 12 | Macro Split Method | (macro split) | Not started |
| 13 | Macro Mix | `selectedMacroId` | Not started |

**Next up: the calorie / macro block (#10–#13)** — Calorie Adjustment Method/Value and Macro Split
Method/Mix.

---

## 3. How the system works (the architecture)

- **`InputStyleManager`** (`TDEE/Models/InputMethod/InputStyleManager.swift`) — the per-input toggle
  store. A global `@Observable`, environment-injected, persisted to `UserDefaults`
  (`input.style.preferences`, string-keyed `[String: String]`). Mirrors `ThemeManager`. An input with
  no stored preference falls back to `.classic` (Decision 5). Inputs are the `InputID` enum; sections
  are `InputSection` (Personal / Activity / Body Fat / Calories / Macros).
- **`InputMethodView`** (`TDEE/Pages/InputMethodPage/InputMethodView.swift`) — the **presenter**: a
  `List` grouping every `InputID` by section, one Classic/New segmented toggle per row. This already
  lists all inputs — **you do not add a row here** when you add an input; the row already exists.
- **`MainSectionProfileInput`** (`TDEE/Pages/MainPage/MainSectionProfileInput.swift`) — the **section
  factory**. One `@ViewBuilder` per input (`genderSection`, `ageSection`, …) that switches on
  `inputStyle.style(for: .xxx)` and returns the `XxClassicSectionView` or `XxNewSectionView`. **This
  is the single composition point** — wiring a new section is a one-line change to its `.new` case.
- **`XxClassicSectionView` / `XxNewSectionView`** (`TDEE/ViewSections/`) — per-input section views.
  Classic carries no style logic (it's just today's section, renamed with a `…Classic` suffix per
  Decision 8). New is the redesign.
- **Controls** (`TDEE/ViewsValueEditors/`) — the actual input widgets (`UISegment*`,
  `UIWheelPicker*`, `…MenuButtonView`, `…TextFieldEntry`).
- **Validators / ranges** (`TDEEShared/`) — `Config/MetricRanges.swift` (the single range authority)
  and `Models/ProfileViewModel/XxxEntry.swift` (pure `(unit, fields) → status` validators).

Existing New sections: `GenderNewSectionView`, `AgeNewSectionView`, `WeightNewSectionView`,
`HeightNewSectionView`, `ActivityLevelNewSectionView`.
Existing controls: `UIActivityLevelMenuButtonView`, `UIHeightUomMenuButtonView`,
`UIWeightUomMenuButtonView`, `UIHeightTextFieldEntry`, `UIWeightTextFieldEntry`.
Existing validators: `WeightEntry`, `HeightEntry`.

**Two shapes of input, two patterns to copy:**
- **Single categorical / single numeric** (Gender, Activity Level, Age): copy `GenderNewSectionView` /
  `AgeNewSectionView`. Inline control in the section header, no expand panel.
- **UOM + value, two pieces over one model** (Weight #3/#4, Height #5/#6): copy `WeightNewSectionView`
  / `HeightNewSectionView`. The one section composes two slots that each honor their own toggle over the
  shared unit-less model (kg/cm) — Decision 11. The UoM piece is a neutral menu button; the value piece
  is a text-field entry (1 field for the "single" unit, 2 for the compound unit).

---

## 4. The recipe — how to add the next "New" section

Work in this order. Confirm the **New-control shape with the owner first** (it is a per-input open
decision — §8); the pattern below is the implementation once the shape is chosen.

1. **Choose the shell.** Categorical/single-numeric → copy `GenderNewSectionView`. UOM+value → copy
   `WeightNewSectionView`/`HeightNewSectionView`.
2. **Create the control(s)** in `TDEE/ViewsValueEditors/`:
   - neutral menu button → copy `UIActivityLevelMenuButtonView` / `UIWeightUomMenuButtonView`
   (`Menu { ForEach … Button { model.x = … } } label: { Text("…") }`, `.accessibilityIdentifier`).
   - numeric text entry → copy `UIWeightTextFieldEntry` (per-field `@State` buffers, in-field UoM
     suffix, `.numberPad`, commit-on-complete-and-in-range, `@FocusState` Done key).
3. **If the input has a range / zero gate** (weight, height did; body fat does — see §6):
   - add the range to `MetricRanges` (single authority), e.g. `MetricRanges.bodyFatPercentage`.
   - write a pure validator `XxxEntry` in `TDEEShared/Models/ProfileViewModel/` returning
     `.ok / .empty / .outOfRange / .unparseable`, committing only on a complete in-range entry.
   - **Move BOTH gates together** (Decision 14): `isXValid` in
     `TDEEShared/Models/ProfileViewModel/ProfileViewModelValidation.swift` **and**
     `validateForCalculation()` in `TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift`.
     *Caveat for body fat: see §6 — the results gate (`isValid`/`hasError`) does NOT compose body fat
     today, so the asymmetry is different.*
   - add `XxxEntryTests` (Swift Testing) covering the validator, the range, and that both gates agree
     (copy `WeightEntryTests` / `HeightEntryTests`).
4. **Wire the factory.** In `MainSectionProfileInput`, point the input's `.new` case at the new
   `XxNewSectionView`. (UOM+value inputs switch on *both* toggles and route any "New" to the composing
   section, mirroring `weightSection`/`heightSection`.)
5. **Leave the Classic path untouched** (see §5 guardrails).
6. **Build + test** (§7).
7. **Update docs** (§5) and commit.

---

## 5. Guardrails & conventions (read before editing)

- **DO NOT MODIFY the Classic controls** — they carry `// AI AGENT WARNING: DO NOT MODIFY` headers and
  approval-required notes. The New section is a **new file**; you change only the factory's `.new` case.
  Protected families: `UIWheelPicker*View` (age/weight/height/bodyFat/activityLevel),
  `UISegment*View` (gender/uomWeight/uomLength/bodyFatCalcMethod/calorieAdjustmentMethod/macroSplitMethod),
  `UISliderCalorieAdjustmentValue`, and the `SectionEditor*` files (`ViewSectionEditors/`).
  Exception noted in `story.md`: an *array literal* in a wheel picker may be edited to source
  `MetricRanges` (that's how Age/Weight/Height got their single-authority ranges) — only with owner
  approval, and only that one line.
- **Two gates move together** for any range-gated input (`isXValid` **and** `validateForCalculation()`),
  or the results view and the calc pre-check drift apart.
- **`MetricRanges` is the single range authority** — bounds live there, not hard-coded in controls.
- **Numeric entry is integer this story** (`.numberPad`; weight/height/age). Decimals were deliberately
  deferred (Decision 17). *Body fat % is the exception that needs decimals — see §6.*
- **New `.swift` files auto-join the target** — the project uses Xcode *synchronized folders*
  (`PBXFileSystemSynchronizedRootGroup`), so **no `project.pbxproj` edit** is needed to add a file.
- **`TDEEShared` compiles into the app targets** — shared helpers are reachable without `import`
  (see project memory).
- **Watch target is out of scope** (`TDEEWatch` keeps its own input UI — Decision 6).
- **Doc cadence (do this every pass):**
  - `story.md`: the Inputs-table row Status → `Done`; the Tasks "are Done …" sentence; append a
    `## Status` dated `Done (YYYY-MM-DD) — input #N (…) converted Classic→New.` entry; update Open
    Questions 1/2 if relevant.
  - `plan.md`: add a `## <Input> pass (input #N) — built (Done, YYYY-MM-DD)` section with Decisions /
    Files / Testing checklist.
  - Commit feat + docs together (the repo's established pattern).

---

## 6. Body Fat (#7 / #8) — built (Done, 2026-10-20)

Two inputs over one section — the most involved pass: the first decimal entry, a show/hide gate
(method → % field), and an asymmetric range gate. **Built** — see the **Body Fat pass** in `plan.md`
and Decisions 18–21 in `story.md`. The three wrinkles below were the design rationale; all resolved:
a single 1-dp `%` field (round on commit), a method-gated `isBodyFatValid` in the results gate, and
`MetricRanges.bodyFatPercentage = 5...50` as the single authority.

- **#8 Body Fat Calc Method** — `bodyFatPercentageMethod`, a 3-case enum
  (`BodyFatOption: omit / estimate / manualEntry`), Classic control `UISegmentBodyFatCalcMethodView`
  (segmented, DO NOT MODIFY). Small — likely an inline segmented or a neutral menu, like Gender.
- **#7 Body Fat %** — `bodyFatPercentage`, a **Double** (e.g. `15.7`), Classic control
  `UIWheelPickerBodyFatView` (two wheels: integer 0–99 + decimal 0–9, DO NOT MODIFY).

**Wrinkles to design around (none of these exist in the prior passes):**
1. **Decimals.** Body fat % is a `Double`; every prior numeric pass was integer. This is the first
   decimal entry — the `.numberPad`/integer simplification (Decision 17) does **not** apply. Decide the
   decimal UI and whether to revise the "integer this pass" decision.
2. **Method gates the value (show/hide, not a unit switch).** `SectionEditorBodyFatPercentage`
   (`ViewSectionEditors/`, DO NOT MODIFY) uses `UILayoutExpandingPanel` on
   `model.bodyFatPercentageShowManualEntry`: when method is **Omit/Estimate the % picker is hidden**;
   when **Manual Entry** it's shown. So the New section must compose the **method toggle + a
   conditional % entry** — analogous to weight/height's two-piece composition (Decision 11), but the
   relationship is a *gate* (Omit/Estimate → no % field) rather than a unit re-derivation.
3. **Asymmetric range gate.** The body-fat range is **5–50%** and lives **only** in
   `validateForCalculation()` (`CalculationValidatePerson.swift:25`, the `.manualEntry` branch),
   **not** in the results gate — `isValid`/`hasError` (`ProfileViewModelValidation.swift`) compose only
   `isAgeValid`/`isWeightValid`/`isHeightValid`. So the "two gates move together" rule (Decision 14)
   applies differently: moving the range touches `validateForCalculation()` but the results `isValid`
   gate does **not** include body fat. Decide whether to extract the 5–50 to `MetricRanges` (single
   authority, like the others) and whether the results gate should start composing it.
4. **No `MetricRanges` entry yet** for body fat.

---

## 7. Build & test

Use the **`/compile` skill** (or run it by hand):

```
xcrun xcodebuild -project TDEE.xcodeproj -scheme TDEE -configuration Debug \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
# append `test` instead of `build` to run TDEETests (Swift Testing)
```

- **Default destination is `generic/platform=iOS Simulator`** — it builds for *any* installed iOS
  simulator and never breaks on runtime churn.
- **The `name=` gotcha (learned this session):** `-destination 'name=iPhone 17 Pro Max'` expands to
  `OS:latest`, and the 27.2 toolchain's "latest" has no `iPhone 17 Pro Max` (it only exists on 27.0),
  so xcodebuild fails with *"Unable to find a device matching the provided destination specifier"*.
  Fixes: use `generic/platform=iOS Simulator`, or pin the runtime (`…,name=iPhone 17 Pro Max,OS=27.0`),
  or target by UDID (`id=<UDID>` from `xcrun simctl list devices`). The `/compile` skill already
  defaults to the generic form.
- **Check the real exit code, not a piped `tail`.** `xcodebuild … | tail` reports `tail`'s exit (0)
  even when xcodebuild failed (exit 70). Capture `xcodebuild …; echo "exit=$?"` or redirect to a log
  and grep for `** BUILD SUCCEEDED **`.
- A booted simulator is fine to build against. Verify the code compiles on at least one installed
  destination; manual UI checks are the owner's.

---

## 8. Open threads (decisions the owner makes)

1. **Per-input "New control shape" (Open Question 1)** — defined as each input's turn comes,
   owner-directed. Body fat's (#7/#8) is now defined (Decisions 18–21); the next undecided one is the
   calorie / macro block (#10–#13).
2. **Rollout order (Open Question 2)** — owner directs; the table order is a placeholder. Done so far:
   Gender, Age, Weight (#3/#4), Height (#5/#6), Activity Level (#9).
3. **Persistence scoping (Open Question 3)** — currently **global** (like the theme), via
   `InputStyleManager` in `UserDefaults`. Whether the per-input preferences should instead be
   **per-profile** (given story 021's multiple profiles) is open — not implemented.
4. **Profile name as a 14th input (Open Question 4)** — out of this pass.
5. **Activity Level neutral closed label** — the New menu's closed label is the neutral string
   "Activity Level" (current pick visible only when opened). The owner is **happy with it as the final
   form** (2026-10-20); surfacing the pick in the closed label was considered and deferred.

---

## 9. File map (the pieces you'll touch)

| Concern | File |
|---------|------|
| Toggle store | `TDEE/Models/InputMethod/InputStyleManager.swift` |
| Presenter (all toggles) | `TDEE/Pages/InputMethodPage/InputMethodView.swift` |
| **Section factory (wire here)** | `TDEE/Pages/MainPage/MainSectionProfileInput.swift` |
| New sections (copy these) | `TDEE/ViewSections/{Gender,Age,Weight,Height,ActivityLevel}NewSectionView.swift` |
| Neutral menu buttons (copy) | `TDEE/ViewsValueEditors/{UIActivityLevel,UIHeightUom,UIWeightUom}MenuButtonView.swift` |
| Text-field entries (copy) | `TDEE/ViewsValueEditors/{UIHeight,UIWeight}TextFieldEntry.swift` |
| Pure validators (copy) | `TDEEShared/Models/ProfileViewModel/{WeightEntry,HeightEntry}.swift` |
| Range authority | `TDEEShared/Config/MetricRanges.swift` |
| Results gate | `TDEEShared/Models/ProfileViewModel/ProfileViewModelValidation.swift` |
| Calc pre-check gate | `TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift` |
| Body fat (next) | `TDEE/ViewSections/BodyFatPercentageClassicSectionView.swift`, `TDEE/ViewSectionEditors/SectionEditorBodyFatPercentage.swift`, `TDEE/ViewsValueEditors/{UIWheelPickerBodyFatView,UISegmentBodyFatCalcMethodView}.swift`, `TDEEShared/Enums/BodyFatOption.swift` |
| Classic controls — DO NOT MODIFY | `TDEE/ViewsValueEditors/UI*` and `TDEE/ViewSectionEditors/SectionEditor*` (the ones with the `AI AGENT WARNING` headers) |

---

## 10. Recent commits (context)

```
a3c172c docs: mark Activity Level input #9 closed (owner-verified) in story 023
f6724c5 fix(compile skill): default destination → generic/platform=iOS Simulator
59a624a feat: Activity Level New section — neutral menu button in the header (story 023, input #9)
984f884 fix(compile skill): resolve Xcode dynamically via xcrun, drop hardcoded path
504c76f feat: Height New section — inline numeric entry with range validation (story 023, inputs #5/#6)
6b3459b docs: mark Weight inputs #3/#4 Done in story 023
2dab512 feat: Weight New section — inline numeric entry with range validation (story 023, inputs #3/#4)
d8174d3 feat: Age New section — inline numeric input with range validation (story 023, input #2)
5fca18e feat: Gender New section — inline segmented control in the header (story 023, input #1)
3260ab8 feat: main input section factory with Classic/New suffix (story 023, Decision 8)
```
