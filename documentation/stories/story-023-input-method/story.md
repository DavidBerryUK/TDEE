# Story 023: Input Method

**Objective:** Give every input its own **`UISegment`-style toggle — "Classic" vs "New"** — so the user
can pick, per input, between **Classic** (today's control) and **New** (that input's redesigned
control). We roll this out **one input at a time** (see the Inputs table below); each input starts
Classic and is converted to a "New" control in its own pass. Preferences persist, stored the same way
the theme is, and each editor reads its own input's choice.

## Background

- **All numeric input is wheel pickers today.** `TDEE/ViewsValueEditors/` has
  `UIWheelPickerAgeView`, `UIWheelPickerHeightView`, `UIWheelPickerWeightView`,
  `UIWheelPickerBodyFatView`, `UIWheelPickerActivityLevelView`, and
  `UIWheelPickerMacroMixView` — each a `.pickerStyle(.wheel)`. There is **no keyboard/text entry**
  anywhere in the app.
- **Categorical input is segmented; one value is a slider.** `UISegment*` (Gender, UomLength,
  UomWeight, BodyFatCalcMethod, CalorieAdjustmentMethod, MacroSplitMethod) are `.pickerStyle(.segmented)`;
  `UISliderCalorieAdjustmentValue` is the lone `Slider`.
- **The persisted-setting pattern already exists.** `ThemeManager`
  (`TDEE/Models/Theme/ThemeManager.swift`) holds a selected theme + appearance mode, persisted to
  `UserDefaults`, injected via `.environment` and consumed in `ThemedRoot` (`TDEEApp.swift`).
  The per-input Classic/New preferences follow this same shape — one entry per input.
- **Multiple profiles exist (story 021).** A per-input preference is **global** (like the theme), not
  per-profile — decided on 2026-10-21 (Decision 22; see Open Questions).

## Scope

- Add a **per-input Classic/New preference** — one entry per input (see Inputs table) — following the
  `ThemeManager` → `UserDefaults` → environment pattern.
- **Each input gets an inline `UISegment` toggle** (Classic / New). **Classic** renders today's
  control unchanged; **New** renders that input's redesigned control.
- **Roll out one input at a time.** The Inputs table is the rollout tracker; each input's "New"
  control is designed and built in its own pass, starting from Classic.
- **Both compact and regular layouts honor the preferences** (iPhone and iPad).
- **Minimal persistence.** A new persisted store (UserDefaults, like the theme); **no new SwiftData
  entities**. The store is the global `InputStyleManager` (Decision 22).

## Decisions

Confirmed with the owner:

1. **User-selectable, stored like the theme.** The input style is a persisted user preference
   (UserDefaults-backed, environment-injected — the `ThemeManager` shape), not a fixed or
   layout-driven choice.
2. **Per-input.** Each input — Gender, Age, Weight, Height, and the rest — has its **own** preference;
   each editor reads the style for *its own* input.
3. **Classic / New toggle per input.** Each input carries a `UISegment`-style control with two
   options: **Classic** (today's control, unchanged) and **New** (that input's redesigned control).
   The "New" control is designed per input; an input starts on Classic.
4. **One control at a time, under the owner's guidance.** Each input's Classic→New conversion is its
   own pass; the owner directs the order. The Inputs table is the rollout tracker.
5. **All inputs default to Classic.** With no preference set, an input shows its Classic control
   (today's behaviour).
6. **Watch out of scope.** `TDEEWatch` keeps its own input UI; this story is phone-only.
7. **Task 1 is a presenter view.** Before any per-input "New" control is designed, build a new view
   that presents the per-input Classic/New options to the user — the prerequisite for all per-input
   work.
8. **Classic/New is a suffix on the section view; the main input is a factory.** Each main-input
   section view is named for its style — `AgeClassicSectionView` / `AgeNewSectionView` — and the main
   input's "section factory" (`MainSectionProfileInput`) picks the variant per input from
   `InputStyleManager`. The factory is the single composition point for the main input view's
   sections: adding an input is a line in the factory, and an input's New control drops into its
   `.new` case when it's built. The Classic sections carry no style logic of their own; the branch
   lives in the factory. Scope is the main input view's six sections (Gender, Age, Height, Weight,
   Activity Level, Body Fat %); the results-side sections (calories, macros) adopt the pattern later.
9. **Weight New shape (inputs #3/#4).** No expand/collapse panel — the control lives inline in the
   section header, like `AgeNewSectionView`. Each field carries its **UoM as an in-field trailing
   suffix** (`| 70 kg |`, not a caption outside the border). **kg / pounds → one field;
   stones & pounds → two fields** (stones 0–40, pounds-remainder 0–13). At accessibility sizes the
   two stones fields stack full-width.
10. **Unit switcher.** A neutral **menu button** in compact/regular (`Units ⌄` / a swap glyph, left
    of the value — the value already shows the current unit); at **accessibility sizes** it becomes the
    full-width segmented `UISegmentUomWeightView` **reused verbatim** (the `GenderNewSectionView`
    move). One control, two presentations; the segmented look is deliberately *not* used in compact —
    it's the aesthetic this redesign leaves.
11. **The two toggles stay independent.** `weightUom` (#3) and `weight` (#4) keep their own
    Classic/New toggles; the single weight section **composes two pieces that each honor their own
    toggle, sharing `model.weightUom` / `model.weight`** as the one source of truth. The shipped path
    converts both together; mixed combinations (New menu + Classic wheel, etc.) render but aren't the
    primary target.
12. **Stones remainder: reject and nag.** The pounds field in stones mode is **0–13**; entering 14+
    shows a `UILabelValidationMessage` (e.g. *"Pounds must be 0–13"*) and leaves the last valid value
    — no silent carry into the stones box.
13. **Validation structure.** One authority in kg: add `MetricRanges.weight` (a
    `ClosedRange<Double>`) and gate on it. Per-field **local buffers commit only on a complete,
    in-range entry** (the `AgeNewSectionView` contract, extended to a range); a small pure
    `WeightEntry` validator maps `(unit, fields) → .ok / .empty / .outOfRange / .unparseable`, the
    view shows one section-level message, and the model gate reads only the committed kg. Keyboard:
    `.numberPad` (integer) for all fields this pass — see Decision 16. A unit switch **re-derives the
    display from the stored kg and never mutates the model** (mirrors the wheel's
    `syncStateFromPreviousUnit`).
14. **Two gates move together.** The range check must land in **both** `isWeightValid` *and*
    `validateForCalculation()` (`CalculationValidatePerson.swift`) — they both key on `weight == 0`
    today and must move together or the results view and the calc pre-check disagree.
15. **Weight range.** `MetricRanges.weight = 20...300` kg. Per-unit *input* caps derive from it:
    lb 44–661, stones 0–40 (≈260 kg — weights above the stones ceiling are entered in kg/lb). 20 kg
    (≈44 lb) rejects accidental low entries without excluding any 16–99 adult; 300 kg sits just above
    the Classic's ~260 kg stones cap, so no reachable Classic value becomes invalid.
16. **Integer entry this pass (decimals deferred).** kg/lb/stones all use `.numberPad` (integer),
    matching the Classic's integer wheels — the single biggest simplification: it removes the 1-dp cap,
    the decimal-in-integer-field edge, and the round-trip-drift concern, so the "complex" corner
    collapses to just the stones 0–13 reject (Decision 12). Sub-kilogram precision is a focused future
    enhancement. *(Revises the `.decimalPad` note in Decision 13.)*
17. **Defer two niceties.** (a) No keyboard `Done`/accessory — match Age's bare keyboard; revisit as a
    shared concern when height's two-field (feet+inches) entry is built. (b) Because entry is integer
    (Decision 16) there is no round-vs-floor display concern, so `WeightConvertor` / `displayWeight`
    are **not touched** this pass — no approval needed; the New control displays like the Classic.
18. **Body Fat is one gated two-slot section (Decision 11 analog).** One `BodyFatPercentageNewSectionView`
    composes two pieces that each honor their own Classic/New toggle over the shared model — a **method**
    slot (`bodyFatPercentageMethod`, #8) and a **value** slot (`bodyFatPercentage`, #7) — but the two
    relate by a **gate**, not a unit switch: the value slot is shown **only under `.manualEntry`**
    (Omit / Estimate carry no % value). The section gates on `bodyFatPercentageMethod == .manualEntry`
    **directly**, not via `bodyFatPercentageShowManualEntry` — that flag is the Classic expanding-panel's
    open-state (`SectionEditorBodyFatPercentage` is its only reader) and is left untouched.
19. **Method control (Decision 10 analog).** A neutral `UIBodyFatMethodMenuButtonView` in compact /
    regular — closed label "Method", listing `BodyFatOption.allCases` and rebinding
    `model.bodyFatPercentageMethod` — with the segmented `UISegmentBodyFatCalcMethodView` reused verbatim
    at accessibility sizes and for the Classic toggle. One control, two presentations.
20. **Decimal entry — the story's first (Decision 20).** A single `.decimalPad` field with an in-field
    `%` suffix, parsing a `Double` and **rounding to one decimal place on commit**, matching the Classic's
    integer + decimal wheels (`value = integer + decimal / 10`). A pure `BodyFatPercentageEntry` maps
    `(text) → .ok(Double) / .empty / .outOfRange / .unparseable`. A trailing dot reads as the whole
    number (`"15."` → `15.0`) so the user sees no mid-typing error; only a non-decimal or a multi-dot
    entry is `.unparseable`.
21. **Range — single authority, method-gated in the results gate (Decision 14, asymmetric variant).**
    Extract `MetricRanges.bodyFatPercentage = 5...50` from the hard-coded `5`/`50` in
    `validateForCalculation()`; both `validateForCalculation()` and the entry read it. Unlike weight /
    height, the results `isValid`/`hasError` **start composing** body fat — but **gated on the method**:
    a new `isBodyFatValid` is `MetricRanges.bodyFatPercentage.contains(bodyFatPercentage)` under
    `.manualEntry`, else `true`. An out-of-range manual entry hides the results *and* blocks the calc
    pre-check; Omit / Estimate (default `0.0`, out of range) never trip. Without the method guard every
    Omit / Estimate profile would read as invalid.
22. **Preferences are global, not per-profile (closes Open Question 3).** The per-input Classic/New
    preferences live on the single global `InputStyleManager` (a global `@Observable`,
    environment-injected, persisted to `UserDefaults` under `input.style.preferences`) — mirroring the
    theme, **not** a field on any profile. This is the already-shipped shape, so the decision needs no
    code change: a user's Classic/New choice for an input applies to every profile they switch
    (story 021) to. A per-profile variant was considered and set aside.
23. **Profile name is excluded from the Classic/New rollout (closes Open Question 4).** The profile
    name is a free-text field (`ProfileEditViewPage`, a plain `TextField`), reached only when adding or
    renaming a profile (story 021). It is **not** a 14th input: the Classic/New toggle exists to pick
    *which control* enters an existing typed *value*, and the name has no such axis — it is already a
    plain free-text box with no "Classic" control to switch away from. Free-text / IME handling is a
    separate concern (already listed under Not shared / Out of Scope). No code change; the name stays
    exactly as it is today.

## Inputs (worked one at a time)

Each row is one input and its Classic/New toggle. **Status**: `Not started` → `New designed` →
`In progress` → `Done`. Classic control is the editor listed; "New control" is that input's
redesign, defined when its turn comes.

| # | Input | Model field(s) | Classic control (today) | New control | Status |
|---|-------|----------------|-------------------------|-------------|--------|
| 1 | Gender | `gender` | `UISegmentGenderView` (segmented) | Inline in the section header (no expand panel); reuses `UISegmentGenderView` | Done |
| 2 | Age | `age` | `UIWheelPickerAgeView` (wheel) | Inline numeric text field in the section header (no expand panel); 16–99 via `MetricRanges.age`; error via `UILabelValidationMessage`, out-of-range shows the error and does not commit | Done |
| 3 | Weight UOM | `weightUom` | `UISegmentUomWeightView` (segmented) | Neutral menu button (compact/regular); `UISegmentUomWeightView` reused at accessibility sizes — see Decisions 10–11 | Done |
| 4 | Weight | `weight` | `UIWheelPickerWeightView` (wheel) | Inline numeric field(s): 1 for kg/lb, 2 for stones & pounds, in-field UoM suffix; `MetricRanges.weight` gate, reject-and-nag remainder — see Decisions 9, 12–14 | Done |
| 5 | Height UOM | `heightUom` | `UISegmentUomLengthView` (segmented) | Neutral menu button (compact/regular); `UISegmentUomLengthView` reused at accessibility sizes — see Decisions 10–11 | Done |
| 6 | Height | `height` | `UIWheelPickerHeightView` (wheel) | Inline numeric field(s): 1 for cm/in, 2 for feet & inches, in-field UoM suffix; `MetricRanges.height` gate, reject-and-nag remainder, keyboard Done key — see the height pass | Done |
| 7 | Body Fat % | `bodyFatPercentage` | `UIWheelPickerBodyFatView` (wheel) | Single `.decimalPad` field, in-field `%` suffix, round-to-1-dp commit; shown only under Manual Entry; `MetricRanges.bodyFatPercentage` gate — see Decisions 18–21 | Done |
| 8 | Body Fat Calc Method | `bodyFatPercentageMethod` | `UISegmentBodyFatCalcMethodView` (segmented) | Neutral "Method" menu (compact/regular); segmented reused at accessibility sizes — see Decisions 18–19 | Done |
| 9 | Activity Level | `activityLevel` | `UIWheelPickerActivityLevelView` (wheel) | Neutral menu button in the section header (compact/regular), lists all 9 `ActivityLevel` cases, drops to a full-width line at accessibility sizes; no expand panel, no range/zero gate — see the Activity Level pass | Done |
| 10 | Calorie Adjustment Method | `calorieAdjustmentMethod` | `UISegmentCalorieAdjustmentMethodView` (segmented) | Neutral "Method" menu (compact/regular); segmented reused at accessibility sizes — Decisions 10 / 19 analog | Done |
| 11 | Calorie Adjustment Value | `calorieAdjustment` | `UISliderCalorieAdjustmentValue` (slider) | Single `.numberPad` field, in-field `kCals` suffix, 0–1000 reject-and-nag; shown only under Cut/Bulk (Maintain carries none) — Decision 18 analog | Done |
| 12 | Macro Split Method | `macroSplitMethod` | `UISegmentMacroSplitMethodView` (segmented) | **Dropped** — dead code (see note below) | **Dropped** |
| 13 | Macro Mix | `selectedMacroId` | `UIWheelPickerMacroMixView` (wheel) | Picker-style neutral "Macro Mix" menu over the preset catalog in the expand panel; Classic wheel reused at all sizes — the Macro Mix pass | Done |

Notes:
- Rows 3/4 and 5/6 are the UOM toggle + the value that uses it; the UOM toggle and its value share
  one "New" design, but each still gets its own Classic/New toggle. **For weight this is confirmed
  (Decision 11): the two toggles stay independent and the one section composes both pieces over the
  shared kg model.** **Height (#5/#6) follows the same shape over the shared cm model — the two
  toggles stay independent and the one section composes both pieces.**
- **Input #12 (Macro Split Method) is dropped as dead code (2026-10-21).** `MacroSplitMethod` and its
  segmented control `UISegmentMacroSplitMethodView` were unreferenced outside their own `#Preview` — no
  model field, no composition. The user's "which method" is expressed by **which macro preset is
  selected** (`selectedMacroId`, #13) and by **editing the mix** (Customise / Edit Presets), so a
  separate macro-split-method input is redundant. Both files were deleted and the `macroSplitMethod`
  toggle removed from `InputID`; the live `SectionMacroSplit`, the #13 wheel, and the `macroSplit`
  icon are untouched.
- **Profile name** (a free-text field, story 021) is **excluded** — not a 14th input (Decision 23,
  closes Open Question 4, 2026-10-21): it has no Classic/New axis, and free-text / IME is a separate
  concern. It stays a plain `TextField` in `ProfileEditViewPage`.

## Tasks

1. **Presenter view (first).** A new view listing every input with its Classic/New toggle — the
   surface the user drives. Prerequisite for all per-input work. **Done (2026-10-19):**
   `InputMethodView` + `InputStyleManager`, tested — see Testing.
2. **Per-input conversions.** One control at a time, in the order the owner directs; tick the
   Status column as each goes Classic→New. **Inputs #1 (Gender), #2 (Age), #3/#4 (Weight), #5/#6
   (Height), #9 (Activity Level), #7/#8 (Body Fat), #10/#11 (Calorie Adjustment), and #13 (Macro Mix)
   are Done (Gender/Age/Weight 2026-10-19; Height, Activity Level, Body Fat, and Calorie Adjustment
   2026-10-20; Macro Mix 2026-10-21); input #12 (Macro Split Method) was dropped as dead code
   (2026-10-21 — functionally covered by Macro Mix). Every in-scope input is converted Classic→New; the
   rollout is complete.**

## Not shared / Out of Scope

- **Watch target** — `TDEEWatch` keeps its own input UI; **out of scope** (Decision 6).
- **New SwiftData entities / iCloud sync** — none; the preferences are plain persisted settings,
  not profile data.
- **Free-text / name entry and IME** — international input methods and the profile-name field are
  separate concerns; this story is about *which control* enters the app's existing typed values.
- **Profile model layer** — no change to `ProfileViewModel`, `ProfileStore`, or
  `MacroSplitOptionsModelCollection`; the per-input store is a global *settings* concern, not a profile
  entity (Decision 22 — global, like the theme; not per-profile).

## Acceptance Criteria

- Every input in the table carries a **Classic / New `UISegment` toggle**; the user can pick per input.
- Each choice **persists** across launches (like the theme); an input starts on **Classic**.
- **Classic** renders today's control unchanged — no regression to any input not yet converted.
- Each input's **New** control is designed and built in its own pass before the next.
- Both **compact and regular** layouts honor the preferences with no phone regression.
- **Watch target unchanged** unless a decision brings it in scope.
- The full test suite passes with no regressions in the shared/model layer.

## Open Questions

> **All open questions are closed (2026-10-21).** Q1/Q2 — every in-scope input is Done (#12 dropped);
> Q3 — preferences are global (Decision 22); Q4 — profile name excluded (Decision 23). Retained below
> for context.

1. **Each input's "New" control** — what does the redesign look like per input (e.g. numeric keypad,
   a different layout)? Defined as each input's turn comes, not up front. **Weight's (Decisions 9–14,
   `plan.md`), height's (the height pass, mirroring weight), body fat's (Decisions 18–21, the body fat
   pass in `plan.md`), and calorie adjustment's (the calorie pass, a gated two-slot section mirroring
   body fat) are defined and built; Macro Mix (#13) is Done — see the Macro Mix pass. Input #12
   (Macro Split Method) was dropped as dead code on 2026-10-21.**

   Macro Mix's (#13) shape is **defined and built** (2026-10-21) — a **selector-only swap** inside
   `SectionMacroSplit` (the expand panel, the `SectionMacroMixResults` cards, and the Customise / Edit
   Presets buttons stay unchanged; only the wheel is replaced) with a **Picker-style neutral `Menu`**
   (`UIMacroMixMenuButtonView`) over the dynamic preset catalog. See the Macro Mix pass in `plan.md`.
2. **Rollout order** — which input converts first (a wheel like Age, or a segmented like Gender)?
   The owner directs; the table order is a placeholder. **In practice: Gender, then Age, then Weight
   (#3/#4) — all 2026-10-19, all Done; then Height (#5/#6), Activity Level (#9), Body Fat (#7/#8), and
   Calorie Adjustment (#10/#11) on 2026-10-20, also Done. Input #12 (Macro Split Method) was dropped
   as dead code on 2026-10-21 (the dietary "method" is expressed by preset selection / mix editing, not
   a separate input); Macro Mix (#13) was converted on 2026-10-21, so every in-scope input is Done.**
3. **Persistence home + scoping — RESOLVED (2026-10-21, Decision 22).** A new per-input store
   (`InputStyleManager`, the `ThemeManager` shape), and the preferences are **global** — like the
   theme, not per-profile (given story 021's multiple profiles). This matches the already-shipped
   code, so no change was needed; a per-profile variant was set aside.
4. **Profile name — RESOLVED (2026-10-21, Decision 23).** Excluded, not a 14th input. The name is a
   free-text field (`ProfileEditViewPage`, a plain `TextField`), not a typed-value control — it has no
   Classic/New axis to switch on, and free-text / IME handling is a separate concern. It stays exactly
   as it is today; no code change.

## Testing

### Unit Tests

**File:** `TDEETests/InputStyleManagerTests.swift` (Swift Testing, `@MainActor`)

9 cases over `InputStyleManager` and its `InputID` / `InputStyle` / `InputSection` types — each uses
an isolated `UserDefaults` suite, and a fresh manager over the same suite simulates a relaunch:

- `defaultsToClassic` — every input reads `.classic` when nothing is stored.
- `setStyleUpdatesInPlace` / `setStyleOverwrites` — a set reflects immediately; re-setting keeps a
  single entry, not one per call.
- `newStylePersists` — a `.new` choice survives a relaunch; unchosen inputs stay `.classic`.
- `persistedPlistIsStringKeyed` — the stored plist is `[String: String]` (`["gender": "new"]`); the
  regression guard for the enum-key `NSException` below.
- `resetClearsStore` — `resetToClassic` wipes the store, in place and after a relaunch.
- `invalidStoredValuesFallBackToClassic` — a bad key *or* value is skipped, falling back to
  `.classic`.
- `sectionTitles` / `sectionsPartitionInputs` — the five section titles, and that grouping by section
  drops and duplicates no input (the invariant `InputMethodView` relies on).

All 9 pass; `TDEE` builds and the full `TDEETests` suite passes.

## Status

- **New (2026-10-19)** — story created; intent confirmed (per-input Classic/New `UISegment` toggle,
  rolled out one control at a time under the owner's guidance, persisted like the theme). Decisions
  1–7 locked (default = Classic, watch out of scope, **Task 1 = presenter view**).
- **In Progress (2026-10-19) — Task 1 done.** The presenter view (the per-input Classic/New "input
  type editor") is built and tested:
  - **`InputStyleManager`** (`TDEE/Models/InputMethod/InputStyleManager.swift`) — the persisted store,
    mirroring `ThemeManager`: a global `@Observable` holding a per-input `[InputID: InputStyle]`,
    saved to `UserDefaults` under `input.style.preferences`, injected through the environment; an
    input with no stored preference falls back to `.classic` (Decision 5).
  - **`InputMethodView`** (`TDEE/Pages/InputMethodPage/InputMethodView.swift`) — the presenter: a
    `List` grouping every input by `InputSection` (Personal / Activity / Body Fat / Calories /
    Macros), one Classic/New segmented toggle per row, each reading and writing its own input's choice.
  - **Fix:** the store first persisted `[InputID: String]` (enum keys), which `UserDefaults` rejects
    with an `NSException` ("Attempt to insert non-property list object"). `persist()` now stringifies
    both keys and values (`[String: String]`), matching the loader — guarded by
    `persistedPlistIsStringKeyed`.
  - **Tests:** 9 passing — see Testing.
  - **No input converted yet:** every Inputs-table row is still "Not started" (Task 2 is the rollout).
- **In Progress (2026-10-19) — section factory wired (Decision 8).** The main input view is now a
  "section factory": `MainSectionProfileInput` composes its six main-input sections from
  `InputStyleManager`, choosing each input's `XxClassicSectionView` (its `.new` case falls back to
  Classic until a New control is built, so all inputs currently render Classic). The six sections
  were renamed `Section<X>` → `XxClassicSectionView` (Gender, Age, Height, Weight, ActivityLevel,
  BodyFatPercentage) — type *and* file — and are referenced only by the factory. `TDEE` builds for
  the iOS simulator.
- **Done (2026-10-19) — input #1 (Gender) converted Classic→New.** `GenderNewSectionView`
  (`TDEE/ViewSections/GenderNewSectionView.swift`) — a layout redesign: no expand/collapse panel; the
  segmented control sits inline in the section header with a comfortable trailing gap. The control is
  **reused unchanged** from `UISegmentGenderView` (its *DO NOT MODIFY* file header holds — only the
  placement changed), and `UISectionSummaryValueGender` is now Classic-only. The factory's `.new` case
  (`MainSectionProfileInput.genderSection`) points at it and takes only `model` (a no-expand section
  needs neither `sectionManager` nor `proxy`). `TDEE` builds for the iOS simulator.
- **Done (2026-10-19) — input #2 (Age) converted Classic→New.** `AgeNewSectionView`
  (`TDEE/ViewSections/AgeNewSectionView.swift`) — the app's first text/keyboard entry: no expand
  panel; a numeric `TextField` sits inline in the section header and drops to its own full-width line
  at accessibility sizes. It keeps a local text buffer and commits to `model.age` only when the entry
  parses **and** falls inside the accepted range; an out-of-range or empty entry shows a
  `UILabelValidationMessage` and leaves the model's last valid value untouched. The accepted range
  (16–99) was extracted to **`MetricRanges.age`** (`TDEEShared/Config/MetricRanges.swift`) and the
  wheel picker (`UIWheelPickerAgeView`) now sources `Array(MetricRanges.age)` — the bounds live in one
  place (the array literal was the only edit to that DO NOT MODIFY file, with the owner's approval).
  The factory's `.new` case (`MainSectionProfileInput.ageSection`) points at it and takes only
  `model`. The results gate now reflects age validity: `ProfileViewModel.isAgeValid` is range-based
  (`MetricRanges.age.contains`) and `isValid`/`hasError` compose the per-field checks, so an
  out-of-range or empty age hides the results — not just a zero. `TDEE` builds for the iOS simulator.
- Open Questions 1–4 remain (inputs #1–#2's "New" designs are now defined — inline header / inline
  numeric field). **Next: Task 2 — the next per-input Classic→New conversion** (rollout order per the
  owner).
- **New (2026-10-19) — inputs #3/#4 (Weight) New control designed.** Decisions 9–14 lock the design:
  an inline no-panel section (like Age), an in-field UoM suffix, **1 field for kg/lb vs 2 for
  stones & pounds** (stones 0–40 / pounds-remainder 0–13), a neutral **menu-button unit switcher**
  (full-width segmented `UISegmentUomWeightView` reused at accessibility sizes), the **two toggles
  kept independent** (the one section composes both pieces over the shared kg model), **reject-and-nag**
  on the stones remainder, and a **three-layer validation** over a new `MetricRanges.weight` gate that
  must move **both** `isWeightValid` and `validateForCalculation()`. Now built — see the **Done** entry
  below; the implementation plan is `plan.md` in this folder.
- **Resolved (2026-10-19) — weight open choices.** Decisions 15–17 close the design's loose ends:
  range `20...300` kg (15), **integer entry this pass** so the "complex" corner shrinks to the stones
  0–13 reject (16), and two deferred niceties — no `Done` key and no `WeightConvertor`/`displayWeight`
  touch (17). Design fully locked; now built — see the **Done** entry below.
- **Done (2026-10-19) — inputs #3/#4 (Weight) converted Classic→New.** `WeightNewSectionView`
  (`TDEE/ViewSections/WeightNewSectionView.swift`) — an inline no-panel section, like
  `AgeNewSectionView`, that composes two pieces each honoring its own Classic/New toggle over the
  shared kg model (Decision 11): a **unit switcher** (`UIWeightUomMenuButtonView`, a neutral "Units"
  menu in compact/regular, with the segmented `UISegmentUomWeightView` reused at accessibility sizes)
  and a **value entry** (`UIWeightTextFieldEntry`, one field for kg/lb, two for stones & pounds, each
  with an in-field UoM suffix). Entry is integer this pass (`.numberPad`, Decision 16); the stones
  pounds-remainder is 0–13 and rejects-and-nags on 14+ (Decision 12); a unit switch re-derives the
  display from the stored kg and never mutates the model. A pure `WeightEntry`
  (`TDEEShared/Models/ProfileViewModel/WeightEntry.swift`) maps `(unit, fields) → .ok / .empty /
  .outOfRange / .unparseable` and commits kg only on a complete, in-range entry; the accepted range
  lives in one place as **`MetricRanges.weight` = `20...300` kg**, and both gates move together —
  `isWeightValid` and `validateForCalculation()` now key on it (Decision 14), so an out-of-range or
  zero weight hides the results *and* blocks the calc pre-check. `WeightEntryTests` (Swift Testing)
  cover the validator, the range, and that the two gates agree. The factory's `weightSection`
  (`MainSectionProfileInput`) routes any "New" toggle to `WeightNewSectionView`; all-Classic keeps the
  expand/collapse wheel. The three Classic weight controls stay untouched.
- **Done (2026-10-20) — inputs #5/#6 (Height) converted Classic→New.** Mirrors the weight pass almost
  1:1 — height is `OptionLength { centimeters, inches, feetAndInches }` over a cm model, so the same
  shell, switcher, and validator shape carry over, with feet & inches standing in for stones & pounds.
  Three owner decisions close the height design: **both gates move to the range** (the weight
  Decision 14 analog), **`MetricRanges.height = 100...272` cm**, and the **keyboard `Done` key is
  added now** (weight's Decision 17a had deferred it to "when height's two-field entry is built" —
  this pass). `HeightNewSectionView` (`TDEE/ViewSections/HeightNewSectionView.swift`) — an inline
  no-panel section, like `WeightNewSectionView`, composing two pieces each honoring its own toggle over
  the shared cm model (Decision 11): a **unit switcher** (`UIHeightUomMenuButtonView`, a neutral
  "Units" menu in compact/regular, with the segmented `UISegmentUomLengthView` reused at accessibility
  sizes) and a **value entry** (`UIHeightTextFieldEntry`, one field for cm/inches, two for feet &
  inches, each with an in-field UoM suffix `cm` / `in` / `ft`). Entry is integer (`.numberPad`); the
  feet **inches-remainder is 0–11** and rejects-and-nags on 12+ (Decision 12 analog); a unit switch
  re-derives the display from the stored cm and never mutates the model (Decision 13). The first field
  to carry a keyboard **`Done`** accessory key (`ToolbarItem(placement: .keyboard)`, a `@FocusState`
  dismiss) — intended as the shared pattern to back-port to age / weight later. A pure `HeightEntry`
  (`TDEEShared/Models/ProfileViewModel/HeightEntry.swift`) maps `(unit, fields) → .ok / .empty /
  .outOfRange / .unparseable` and commits cm only on a complete, in-range entry; the accepted range
  lives in one place as **`MetricRanges.height` = `100...272` cm**, and both gates move together —
  `isHeightValid` and `validateForCalculation()` now key on it (Decision 14 analog), so an out-of-range
  or zero height hides the results *and* blocks the calc pre-check. `HeightEntryTests` (Swift Testing)
  cover the validator, the range, and that the two gates agree; the full `TDEETests` suite passes with
  no regression. `LengthConverter` / `displayLength` stay untouched (integer entry → no round-vs-floor
  concern). The factory's `heightSection` (`MainSectionProfileInput`) routes any "New" toggle to
  `HeightNewSectionView`; all-Classic keeps the expand/collapse wheel. The three Classic height
  controls (`UISegmentUomLengthView`, `UIWheelPickerHeightView`, `SectionEditorHeight`) stay untouched.
- **Done (2026-10-20) — input #9 (Activity Level) converted Classic→New.** `ActivityLevelNewSectionView`
  (`TDEE/ViewSections/ActivityLevelNewSectionView.swift`) — an inline no-panel section, like
  `GenderNewSectionView`: a neutral `Menu` labelled "Activity Level" sits in the section header
  (compact / regular) and drops to its own full-width line at accessibility sizes. It lists every
  `ActivityLevel` case (9) and rebinds `model.activityLevel`, so the Classic wheel picker is replaced
  without touching it — `UIWheelPickerActivityLevelView` and `SectionEditorActivityLevel` stay
  untouched. The control is `UIActivityLevelMenuButtonView`
  (`TDEE/ViewsValueEditors/UIActivityLevelMenuButtonView.swift`), mirroring the neutral UoM menu button
  (`UIWeightUomMenuButtonView` / `UIHeightUomMenuButtonView`). Activity level is a categorical pick with
  no range / zero gate, so — unlike the weight and height passes — this needed no `MetricRanges` entry,
  no validator, and no `validateForCalculation()` change; the full `TDEETests` suite passes unchanged.
  `TDEE` builds for the iOS simulator.
- **Done (2026-10-20) — inputs #7/#8 (Body Fat) converted Classic→New.** `BodyFatPercentageNewSectionView`
  (`TDEE/ViewSections/BodyFatPercentageNewSectionView.swift`) — the story's most involved pass: one
  composing section (Decision 11 analog, like weight / height) that relates its two pieces by a **gate**
  rather than a unit switch. It composes a **method** slot (`UIBodyFatMethodMenuButtonView`, a neutral
  "Method" menu over `BodyFatOption.allCases` in compact / regular, with the segmented
  `UISegmentBodyFatCalcMethodView` reused at accessibility sizes — Decision 19) and a **value** slot that
  is **shown only under `.manualEntry`** (Decision 18), gated on `bodyFatPercentageMethod` directly — the
  Classic-only `bodyFatPercentageShowManualEntry` flag is left untouched. The value entry,
  `UIBodyFatPercentageTextFieldEntry`, is the story's first **decimal** control (Decision 20): a single
  `.decimalPad` field with an in-field `%` suffix and a keyboard **`Done`** key, committing only a
  complete, in-range value **rounded to 1 dp** to match the Classic's integer + decimal wheels. The
  accepted range lives in one place as **`MetricRanges.bodyFatPercentage` = `5...50`** (Decision 21), and
  — the asymmetric variant of Decision 14 — both gates move: `validateForCalculation()` reads the range
  under `.manualEntry`, and the results `isValid`/`hasError` now compose a **method-gated**
  `isBodyFatValid` (in range only under `.manualEntry`, else `true`), so an out-of-range manual entry
  hides the results *and* blocks the calc pre-check while Omit / Estimate never trip.
  `BodyFatPercentageEntryTests` (Swift Testing) cover the validator, the range, and that the two gates
  agree — incl. the method-gating; the pre-existing `ProfileViewModelValidationTests` body-fat cases stay
  green. The three Classic controls stay untouched. `TDEE` builds and the full `TDEETests` suite passes
  on iPhone 17 Pro Max / iOS 27.
- **Done (2026-10-20) — inputs #10/#11 (Calorie Adjustment) converted Classic→New.** `CalorieAdjustmentNewSectionView`
  (`TDEE/ViewSections/CalorieAdjustmentNewSectionView.swift`) — one composing section (Decision 11 analog,
  like body fat) that relates its two pieces by a **gate** rather than a unit switch: a **method** slot
  (`UICalorieAdjustmentMethodMenuButtonView`, a neutral "Method" menu over
  `CalorieAdjustmentMethod.allCases` in compact / regular, with the segmented
  `UISegmentCalorieAdjustmentMethodView` reused at accessibility sizes — Decision 19 analog) and a
  **value** slot that is **shown only under Cut / Bulk** (Maintain carries no adjustment), gated on
  `calorieAdjustmentMethod != .maintain` directly — the Classic-only `calorieAdjustmentShowSliders` flag
  (the Classic expanding-panel's open-state; `SectionEditorCalorieAdjustment` is its only reader) is left
  untouched. The value entry, `UICalorieAdjustmentTextFieldEntry`, is a single `.numberPad` field with an
  in-field `kCals` suffix and a keyboard **`Done`** key, committing only a complete, in-range integer
  value. The accepted range lives in one place as **`MetricRanges.calorieAdjustment` = `0...1000`**.
  **Unlike the weight / height / body-fat passes, calorie adjustment carries no results gate** — it is not
  in `isValid` / `hasError` and `adjustCalories` clamps to a non-negative result — so there is **no
  two-gate move**: the range drives only the entry's reject-and-nag, and neither `isValid` nor
  `validateForCalculation()` changes. The three Classic controls (`UISegmentCalorieAdjustmentMethodView`,
  `UISliderCalorieAdjustmentValue`, `SectionEditorCalorieAdjustment`) stay untouched. `CalorieAdjustmentEntryTests`
  (Swift Testing) cover the validator and the range; `TDEE` builds and the full `TDEETests` suite passes
  on the iOS simulator.
- **Planned (2026-10-21) — input #13 (Macro Mix) shape decided.** The last input. Owner-confirmed: a
  **selector-only swap** inside `SectionMacroSplit` — the expand panel, the `SectionMacroMixResults`
  cards, and the Customise / Edit Presets buttons stay unchanged, and only the wheel is replaced — with a
  **Picker-style neutral `Menu`** over the dynamic preset catalog (`Menu { Picker(…selection:
  $profile.selectedMacroId) }`, a checkmark on the current preset, a neutral "Macro Mix" closed label).
  No `MetricRanges` / validator / gate move (like calorie — not in `isValid` / `hasError`). New:
  `UIMacroMixMenuButtonView`; wiring: `SectionMacroSplit` routes on `style(for: .macroMix)`. See the
  Macro Mix pass in `plan.md`. Built and Done the same day — see the entry below.
- **Done (2026-10-21) — input #13 (Macro Mix) converted Classic→New; story rollout complete.** The last
  in-scope input. `UIMacroMixMenuButtonView` (`TDEE/ViewsValueEditors/UIMacroMixMenuButtonView.swift`)
  is a Picker-style neutral `Menu` labelled "Macro Mix" that lists the dynamic preset catalog
  (`MacroSplitOptionsModelCollection.items`) and rebinds `profile.selectedMacroId` — a checkmark on the
  current preset, the Classic wheel `UIWheelPickerMacroMixView` surfaced as a dropdown. `SectionMacroSplit`
  gains `@Environment(InputStyleManager.self)` and routes its selector on `style(for: .macroMix)` —
  `.new` shows the menu, `.classic` keeps `SectionEditorMacroMix` (the wheel) untouched — a
  **selector-only swap** (the expand panel, the `SectionMacroMixResults` cards, and the Customise / Edit
  Presets buttons are unchanged in both branches). **No results gate / no `MetricRanges` / no two-gate
  move** (like calorie — it is not in `isValid` / `hasError`). The Classic path is untouched; no new
  `TDEETests` (there is no pure validator to test — like Activity Level). `TDEE` builds and the full
  `TDEETests` suite passes on the iOS simulator. **This completes the per-input rollout — every in-scope
  input (#1–#11, #13; #12 dropped) is converted Classic→New.**
- **Resolved (2026-10-21) — Open Question 3 (persistence scoping).** The owner confirmed the per-input
  Classic/New preferences are **global** — like the theme, not per-profile (story 021's multiple
  profiles). Recorded as **Decision 22**. This is the already-shipped shape (`InputStyleManager`, a
  global `@Observable` in `UserDefaults`), so no code changed; a per-profile variant was set aside.
- **Resolved (2026-10-21) — Open Question 4 (profile name as a 14th input).** The owner confirmed the
  profile name is **excluded** — it is not a 14th input. Recorded as **Decision 23**. The name is a
  free-text `TextField` in `ProfileEditViewPage` with no Classic/New axis (free-text / IME is a
  separate concern), so it stays exactly as it is; no code change. **This closes the last open question;
  story 023 has no open threads remaining.**
- **Closed (2026-10-22) — story complete.** The per-input rollout is done (every in-scope input,
  #1–#11 and #13, is converted Classic→New; #12 dropped as dead code), all four open questions are
  closed (Q3 global / Decision 22, Q4 excluded / Decision 23), and the story is marked **Done** in the
  stories README. Deferred niceties (Decision 17 — a `Done` key back-ported to Age/Weight, and
  sub-kilogram decimal entry) are explicitly out of this pass and left for future work. `TDEE` builds
  and the full `TDEETests` suite passes on iPhone 17 Pro Max / iOS 27.
