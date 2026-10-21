# Handover — Story 023 (Input Method): per-input Classic/New toggle rollout

**For a fresh agent.** This document is self-contained: read it, then the canonical docs it points
to, and you can continue the rollout. Do **not** rely on any conversation history.

- **Date:** 2026-10-21
- **Branch:** `feat/story-023-input-method` (already renamed; carries Gender/Age/Weight/Height/Activity
  Level/Body Fat/Calorie Adjustment)
- **Project:** TDEE (iOS). Watch target (`TDEEWatch`) is **out of scope**.

---

## 1. Where to look first (canonical docs)

| File | What it is |
|------|-----------|
| `story.md` (this folder) | **Source of truth.** The Inputs table (the rollout tracker + per-input status), the Decisions, Tasks, Open Questions, Status log. |
| `plan.md` (this folder) | Per-pass implementation plans. Each input's pass has a section (Weight, Height, Activity Level, Body Fat, Calorie Adjustment) with Decisions / Files / Testing checklist. |
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
| 10 | Calorie Adjustment Method | `calorieAdjustmentMethod` | **Done** |
| 11 | Calorie Adjustment Value | (slider) | **Done** |
| 12 | Macro Split Method | (macro split) | **Dropped** — dead code (2026-10-21) |
| 13 | Macro Mix | `selectedMacroId` | Not started |

**Next up: Macro Mix (#13)** — the last remaining input. Input #12 (Macro Split Method) was dropped
as dead code: `MacroSplitMethod` + `UISegmentMacroSplitMethodView` were unreferenced outside their
own `#Preview` (no model field, no composition), and the dietary "method" is expressed by preset
selection (`selectedMacroId`, #13) and mix editing — so a separate input was redundant. Both files
were deleted and the `macroSplitMethod` toggle removed from `InputID`.

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
`HeightNewSectionView`, `ActivityLevelNewSectionView`, `BodyFatPercentageNewSectionView`,
`CalorieAdjustmentNewSectionView`.
Existing controls: `UIActivityLevelMenuButtonView`, `UIHeightUomMenuButtonView`,
`UIWeightUomMenuButtonView`, `UIBodyFatMethodMenuButtonView`, `UICalorieAdjustmentMethodMenuButtonView`,
`UIBodyFatPercentageTextFieldEntry`, `UICalorieAdjustmentTextFieldEntry`, `UIHeightTextFieldEntry`,
`UIWeightTextFieldEntry`.
Existing validators: `WeightEntry`, `HeightEntry`, `BodyFatPercentageEntry`, `CalorieAdjustmentEntry`.

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

## 6. The gated two-slot sections — Body Fat (#7 / #8) & Calorie Adjustment (#10 / #11), both Done

The two most involved passes share one shape (Decision 11 analog): **one composing section that
relates its two pieces by a *gate* rather than a unit switch** — a **method** slot (a neutral menu
that, unlike weight/height, decides whether the **value** slot appears at all) and a **value** slot
shown only under certain methods. Both are built; see the passes in `plan.md` and Decisions 18–21
(body fat) plus the calorie entry in `story.md`'s Status log.

### 6.1 Body Fat (#7 / #8) — Done (2026-10-20)

- **#8 Body Fat Calc Method** — `bodyFatPercentageMethod`, a 3-case enum
  (`BodyFatOption: omit / estimate / manualEntry`). New control `UIBodyFatMethodMenuButtonView`
  (neutral "Method" menu in compact/regular; segmented `UISegmentBodyFatCalcMethodView` reused at
  accessibility sizes).
- **#7 Body Fat %** — `bodyFatPercentage`, a **Double** (e.g. `15.7`). New control
  `UIBodyFatPercentageTextFieldEntry`: the story's first **decimal** field (Decision 20) — a single
  `.decimalPad` field with an in-field `%` suffix, committing a value **rounded to 1 dp** to match the
  Classic's integer + decimal wheels; shown **only under `.manualEntry`**, gated on
  `bodyFatPercentageMethod` **directly** (the Classic-only `bodyFatPercentageShowManualEntry`
  expanding-panel flag is left untouched — `SectionEditorBodyFatPercentage` is its only reader).
- **Range — asymmetric two-gate move (Decision 21).** `MetricRanges.bodyFatPercentage = 5...50` is the
  single authority. Both gates move: `validateForCalculation()` reads the range under `.manualEntry`,
  **and** the results `isValid`/`hasError` now compose a **method-gated** `isBodyFatValid` (in range
  only under `.manualEntry`, else `true`) — so an out-of-range manual entry hides the results *and*
  blocks the calc pre-check, while Omit / Estimate (default `0.0`) never trip. This is the *asymmetric*
  variant of Decision 14.
- **Decimals are a permanent exception** to the integer-entry simplification (Decision 17): body fat
  stays `.decimalPad` with 1-dp rounding.

### 6.2 Calorie Adjustment (#10 / #11) — Done (2026-10-20)

The same gated two-slot shape as body fat, simpler in one respect.

- **#10 Calorie Adjustment Method** — `calorieAdjustmentMethod` (`CalorieAdjustmentMethod.allCases`:
  Maintain / Cut / Bulk). New control `UICalorieAdjustmentMethodMenuButtonView` (neutral "Method"
  menu; segmented `UISegmentCalorieAdjustmentMethodView` reused at accessibility sizes).
- **#11 Calorie Adjustment Value** — the Classic is `UISliderCalorieAdjustmentValue` (a `Slider`).
  New control `UICalorieAdjustmentTextFieldEntry`: a single `.numberPad` field with an in-field
  `kCals` suffix + keyboard **`Done`**, shown **only under Cut / Bulk** (Maintain carries none), gated
  on `calorieAdjustmentMethod != .maintain` **directly** — the Classic-only
  `calorieAdjustmentShowSliders` flag (`SectionEditorCalorieAdjustment`'s only reader) is left
  untouched. `MetricRanges.calorieAdjustment = 0...1000`.
- **No results gate (unlike body fat).** Calorie adjustment is **not** in `isValid`/`hasError`, and
  `adjustCalories` clamps to a non-negative result — so there is **no two-gate move**: the range
  drives only the entry's reject-and-nag, and neither `isValid` nor `validateForCalculation()` changes.
- The three Classic controls (`UISegmentCalorieAdjustmentMethodView`,
  `UISliderCalorieAdjustmentValue`, `SectionEditorCalorieAdjustment`) stay untouched.

### What's next: Macro Mix (#13) — the last input

Input #12 (Macro Split Method) was **dropped as dead code** (2026-10-21): `MacroSplitMethod` +
`UISegmentMacroSplitMethodView` were unreferenced outside their own `#Preview` (no model field, no
composition), so the dietary "method" is expressed by preset selection (`selectedMacroId`, #13) and by
editing the mix — not a separate input. Both files were deleted and the `macroSplitMethod` case removed
from `InputID`.

**#13 Macro Mix** is the final input, and the hardest remaining shape: it is **not** a fixed enum or a
numeric entry — `UIWheelPickerMacroMixView` (the last wheel) is a selection over
**`MacroSplitOptionsModelCollection.items`**, a dynamic, SwiftData-backed, user-editable preset catalog
(name + protein/carbs/fats + ordinal + `isCustom`). Composed in `UIMainView → MainSectionMacroMix →
SectionMacroSplit` (not the `MainSectionProfileInput` factory), the wheel sits *inside* that section's
editor alongside `SectionMacroMixResults` and the "Customise" / "Edit Presets" buttons, and the control
reads `@Environment(MacroSplitOptionsModelCollection.self)` (so a New control must take the collection,
not just `model`). **No results gate** (like calorie — `isValid`/`hasError` = age+weight+height+bodyFat
only), so no two-gate move. See §8, open thread 1 — the New-control shape is an owner decision (a
neutral `Menu` over the dynamic catalog is the leading candidate), define it before building.

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
   owner-directed. Body fat's (#7/#8, Decisions 18–21) and calorie adjustment's (#10/#11, a Decision
   18/19 analog) are now defined and built; the last undecided one is **Macro Mix (#13)** — a neutral
   `Menu` over the dynamic preset catalog is the leading candidate. Input #12 (Macro Split Method) was
   **dropped as dead code** (2026-10-21).
2. **Rollout order (Open Question 2)** — owner directs; the table order is a placeholder. Done so far:
   Gender, Age, Weight (#3/#4), Height (#5/#6), Activity Level (#9), Body Fat (#7/#8), and
   Calorie Adjustment (#10/#11). #12 was dropped; the last input is Macro Mix (#13).
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
| New sections (copy these) | `TDEE/ViewSections/{Gender,Age,Weight,Height,ActivityLevel,BodyFatPercentage,CalorieAdjustment}NewSectionView.swift` |
| Neutral menu buttons (copy) | `TDEE/ViewsValueEditors/{UIActivityLevel,UIHeightUom,UIWeightUom,UIBodyFatMethod,UICalorieAdjustmentMethod}MenuButtonView.swift` |
| Text-field entries (copy) | `TDEE/ViewsValueEditors/{UIHeight,UIWeight,UIBodyFatPercentage,UICalorieAdjustment}TextFieldEntry.swift` |
| Pure validators (copy) | `TDEEShared/Models/ProfileViewModel/{WeightEntry,HeightEntry,BodyFatPercentageEntry,CalorieAdjustmentEntry}.swift` |
| Range authority | `TDEEShared/Config/MetricRanges.swift` |
| Results gate | `TDEEShared/Models/ProfileViewModel/ProfileViewModelValidation.swift` |
| Calc pre-check gate | `TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift` |
| Body fat (next) | `TDEE/ViewSections/BodyFatPercentageClassicSectionView.swift`, `TDEE/ViewSectionEditors/SectionEditorBodyFatPercentage.swift`, `TDEE/ViewsValueEditors/{UIWheelPickerBodyFatView,UISegmentBodyFatCalcMethodView}.swift`, `TDEEShared/Enums/BodyFatOption.swift` |
| Classic controls — DO NOT MODIFY | `TDEE/ViewsValueEditors/UI*` and `TDEE/ViewSectionEditors/SectionEditor*` (the ones with the `AI AGENT WARNING` headers) |

---

## 10. Recent commits (context)

```
c857199 feat: Calorie Adjustment New section — gated method menu + kCals entry (story 023, inputs #10/#11)
094a006 feat: Body Fat New section — gated method + 1-dp % entry (story 023, inputs #7/#8)
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
