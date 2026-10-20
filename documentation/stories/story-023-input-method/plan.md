# Plan: Story 023 — Weight "New" section (inputs #3 Weight UOM, #4 Weight)

Build the redesigned **Weight** input — the app's first input that needs **1 vs 2 fields, a unit
switcher, and cross-unit validation**. It follows the `AgeNewSectionView` shell (inline, no expand
panel, buffer-and-commit, `UILabelValidationMessage`) and reuses the shared UoM / conversion pieces,
but adds a stones-and-pounds two-field case, a neutral unit switcher, and a `MetricRanges.weight`
gate. The three Classic weight controls (`UISegmentUomWeightView`, `UIWheelPickerWeightView`,
`SectionEditorWeight`) stay **untouched** — the New section composes them where a toggle is Classic.

> **Cadence.** Story 023 rolls out one input at a time. This `plan.md` covered the **weight pass**
> (#3/#4); future passes (height, body fat, …) extend or follow this file. **Status: built (Done,
> 2026-10-19)** — Decisions 9–17 in `story.md` are locked and implemented; `WeightEntryTests` pass.

## Decisions (from story.md, Decisions 9–14)

- **Shape** (#9): inline, no expand panel; in-field trailing UoM suffix; **kg/pounds = 1 field,
  stones & pounds = 2** (stones 0–40, pounds-remainder 0–13); stones fields stack at a11y sizes.
- **Switcher** (#10): neutral **menu button** in compact/regular; full-width `UISegmentUomWeightView`
  **reused verbatim** at accessibility sizes. One control, two presentations.
- **Independent toggles** (#11): the one section **composes two pieces** (switcher from `weightUom`,
  value from `weight`), each honoring its own toggle, over the shared `model.weightUom` /
  `model.weight`. Shipped path converts both together; mixed combinations render but aren't primary.
- **Stones remainder** (#12): **reject and nag** — the pounds field is 0–13; 14+ shows a message and
  leaves the last valid value (no silent carry).
- **Validation** (#13): `MetricRanges.weight` (a kg `ClosedRange<Double>`) as the single authority;
  per-field **local buffers commit only on a complete, in-range entry**; a pure `WeightEntry`
  validator → `.ok / .empty / .outOfRange / .unparseable`; whole-form gate + per-field highlight;
  `.numberPad` (integer) for every field, per Decision 16; a unit switch **re-derives display from
  the stored kg and never mutates the model**.
- **Two gates** (#14): move the range into **both** `isWeightValid` *and* `validateForCalculation()`
  — they both key on `weight == 0` today.
- **Range** (#15): `MetricRanges.weight = 20...300` kg; input caps lb 44–661, stones 0–40.
- **Integer entry** (#16): kg/lb/stones all `.numberPad` (integer), matching the Classic — collapses
  the "complex" corner to just the stones 0–13 reject. Decimals deferred.
- **Deferred niceties** (#17): no keyboard `Done` (match Age); `WeightConvertor` / `displayWeight`
  **untouched** (integer entry means no round-vs-floor concern, so no approval needed).

## The core tension (read first)

Two things make weight unlike the Age/Gender passes:

1. **The field count changes with the unit** — kg/lb render one field, stones & pounds render two.
   The value entry is a *parameterised* control, not a single field.
2. **The unit switcher and the value entry are two separately-toggled pieces that must stay in sync
   over one shared model.** With "toggles independent," the section can present any of four
   combinations (Classic/Classic, New/Classic, Classic/New, New/New); all four must render without
   layout collapse, and the shipped path is **New/New**.

The validation "complexity" the owner senses is concentrated in the **stones↔remainder + decimals +
unit-switch** corner; kg/lb are essentially the Age pattern. **Decision 16 (integer entry) removes the
decimals leg of that corner outright**, leaving just the stones 0–13 reject and the unit-switch
re-derivation — genuinely small. What remains is *containable* by three rules: one kg authority,
per-field buffers that commit only when complete, and a pure validator the view drives. The one thing
to lock early — **reject-and-nag** on the remainder (#12), with **range-on-blur, parse-on-type** so
we don't nag mid-entry — is what keeps the "complex" feeling from reaching the user.

## Design

### Section composition
- **`WeightNewSectionView`** (new, `TDEE/ViewSections/`): the inline no-panel shell, like
  `AgeNewSectionView` — takes only `model`; the control drops to its own full-width line at
  accessibility sizes; a `UILabelValidationMessage` sits under the header.
- It composes two slots, each honoring its own toggle:
  - **Switcher slot** (`weightUom`): `.new` → new `UIWeightUomMenuButtonView` (a menu binding
    `$model.weightUom`); `.classic` → `UISegmentUomWeightView` reused.
  - **Value slot** (`weight`): `.new` → new `UIWeightTextFieldEntry` (1 or 2 fields, binding
    `$model.weight` + `$model.weightUom`); `.classic` → `UIWheelPickerWeightView` reused.
- **Layout rule:** when the value is `.new` (text fields) the section is inline (no panel); when the
  value is `.classic` (a 150 pt wheel) the section keeps today's expand/collapse container. The New
  switcher lives in the header; the *already-established* tight-size rule (drop to its own line /
  stack) absorbs any mixed-combination squeeze — no new layout logic.
- **Factory wiring:** `MainSectionProfileInput.weightSection` today switches on `.weight` only and
  must read **both** `.weightUom` and `.weight` so the composition honors both toggles. The presenter
  (`InputMethodView`) already lists the two toggles separately — no change there.

### The value entry (`UIWeightTextFieldEntry`)
- One field for kg/lb, two for stones & pounds (stones then pounds), each with an **in-field trailing
  UoM suffix** reusing the `UITextPickerLabel` voice/color (`unitOfMeasureColor`). Two matched boxes
  make "11 st 3 lb" structurally impossible to misread as one value.
- **Keyboard:** `.numberPad` (integer) for every field — kg, lb, and the two stones fields
  (Decision 16). Matches the Classic's integer wheels; no decimal surface area this pass.
- **Buffers:** one `@State` string per field, seeded on appear and **re-derived when `weightUom`
  changes** (convert the stored kg → the field's display value, *integer, as the Classic displays
  it*).
- **Stones fields:** stones 0–40, pounds-remainder 0–13; a pounds entry ≥ 14 is **rejected** with a
  message (#12), not carried.
- **No `Done` key (Decision 17):** match Age's bare keyboard for this pass; revisit as a shared
  concern when height's two-field entry is built.

### The switcher (`UIWeightUomMenuButtonView`)
- A `Menu` (or a swap-glyph button) labelled `Units ⌄`, placed in the header left of the value; the
  value already shows the current unit, so the button need not repeat it.
- At accessibility sizes the section instead shows the full-width `UISegmentUomWeightView` reused
  verbatim (#10).

### Validation
- **`MetricRanges.weight`**: a `ClosedRange<Double>` in kg, `20...300` (Decision 15). Per-unit
  *display/input caps* are derived from it (lb 44…661, stones 0…40, remainder 0…13).
- **`WeightEntry`** (pure, unit-testable): `(unit, fields) -> (status, kg?)` with
  `.ok / .empty / .outOfRange / .unparseable`. Stones fold via
  `WeightConvertor.toKilograms(stones:pounds:)`; lb/kg parse the integer.
- **Gates (#14):** replace `weight == 0` with `MetricRanges.weight.contains(weight)` in **both**
  `ProfileViewModelValidation.isWeightValid` **and** `CalculationValidatePerson.validateForCalculation()`
  — in the *same change*, or results and calc pre-check drift apart.
- **Display (#17):** not touched this pass — integer entry means the New control displays exactly like
  the Classic, so `WeightConvertor` / `displayWeight` stay as-is (no approval needed).
- **Unit switch (#13):** re-derive the buffers from the stored kg (never rewrite `weight`); any
  round-trip drift is display-only and only "sticks" if the user then edits.
- **Error copy (one section-level `UILabelValidationMessage`):** *"Weight is required"* (empty),
  *"Weight must be 20–300 kg"* / *"…44–661 lb"* / *"…0–40 st"* (out of range, in the current unit),
  *"Enter a valid weight"* (unparseable), *"Pounds must be 0–13"* (stones remainder ≥ 14).

## Files

| File | Change |
|------|--------|
| `TDEE/ViewSections/WeightNewSectionView.swift` | **New** — inline no-panel section; composes the switcher + value slots; a11y line-drop; `UILabelValidationMessage`. |
| `TDEE/ViewsValueEditors/UIWeightUomMenuButtonView.swift` | **New** — neutral menu-button unit switcher (binds `weightUom`); full-width `UISegmentUomWeightView` reused at a11y sizes. |
| `TDEE/ViewsValueEditors/UIWeightTextFieldEntry.swift` | **New** — 1- or 2-field numeric entry with in-field UoM suffix; per-field buffers; drives `WeightEntry`. |
| `TDEEShared/Models/…/WeightEntry.swift` (new, or a validation extension) | **New** — the pure `(unit, fields) -> (status, kg?)` validator. |
| `TDEEShared/Config/MetricRanges.swift` | **Change** — add `weight: ClosedRange<Double>` (kg). |
| `TDEEShared/Models/ProfileViewModel/ProfileViewModelValidation.swift` | **Change** — `isWeightValid` → range-based. |
| `TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift` | **Change** — `validateForCalculation()` weight check → range-based, kept in sync with `isWeightValid`. |
| `TDEEShared/Utilities/WeightConvertor.swift` + `displayWeight.swift` | **Not touched this pass** (Decision 17) — integer entry means the New control displays like the Classic; the existing converter is reused as-is. |
| `TDEE/Pages/MainPage/MainSectionProfileInput.swift` | **Change** — `weightSection` reads both `.weightUom` and `.weight`; the `.new` case points at `WeightNewSectionView`. |
| `TDEETests/…/WeightEntryTests.swift` (new) | **New** — unit tests for the validator, `MetricRanges.weight`, and both gates. |

**Reused as-is:** `AgeNewSectionView` (shell/pattern), `UISegmentUomWeightView` (a11y segmented),
`UIWheelPickerWeightView` (Classic value), `UITextPickerLabel` (UoM voice),
`UILabelValidationMessage` (error), `WeightConvertor.toKilograms(stones:pounds:)` (exact commit).
**Do NOT modify without approval:** `UISegmentUomWeightView`, `UIWheelPickerWeightView`,
`SectionEditorWeight` (the Classic path).

## Testing checklist

- [x] `WeightEntry.validate` — valid kg, valid lb, valid stones (0–40 + 0–13), reject lb ≥ 14,
      out-of-range, empty, unparseable (all units; integer entry, so no decimal case).
- [x] `MetricRanges.weight` contains / not-contains.
- [x] **Both gates** (`isWeightValid` *and* `validateForCalculation()`) reflect the range — an
      out-of-range or zero weight hides results **and** blocks calc.
- [ ] Unit switch re-derives the display without mutating `weight`; the round-trip is display-only
      (view-layer — no unit test; manual).
- [ ] `TDEE` + `TDEEWatch` build; full `TDEETests` suite passes (run:
      `xcodebuild -project TDEE.xcodeproj -scheme TDEE -configuration Debug test`).
- [ ] Manual (iPhone compact): menu switcher, 1-field kg/lb, 2-field stones, error messages —
      **manual**.
- [ ] Manual (iPad regular + accessibility sizes): full-width segmented switcher; stones fields
      stack — **manual**.

## Risks

- **Two gates drifting** — the range must land in `isWeightValid` *and* `validateForCalculation()`
  in the same change, or the results view and the calc pre-check disagree.
- **Mixed-toggle layout** — all four combinations must each render; lean on the existing a11y
  line-drop / stack rather than new layout logic, and verify the New-menu + Classic-wheel combo
  doesn't collapse.
- **Resolved (Decisions 15–17):** range is `20...300` kg; integer entry removes the `floor`/`round`
  display concern and leaves `WeightConvertor` / `displayWeight` untouched; no `Done` key this pass.
  No approval-gated file is in the change set.

---

## Height pass (inputs #5/#6) — built (Done, 2026-10-20)

Height mirrors the weight pass almost 1:1: `OptionLength { centimeters, inches, feetAndInches }` over a
**cm** model, so the shell, switcher, and validator carry over with **feet & inches standing in for
stones & pounds**. Three owner decisions close the height design; everything else follows Decisions 9–17.

### Decisions (this pass)

- **Both gates move to the range** (Decision 14 analog): `isHeightValid` *and*
  `validateForCalculation()` key on `MetricRanges.height`, so the results view and the calc pre-check
  can't drift — the same move weight made.
- **Range:** `MetricRanges.height = 100...272` cm. 100 cm (≈3 ft 3 in) rejects accidental low entries
  without excluding any 16–99 adult; 272 cm matches the Classic wheels' reach (~8 ft 11 in), so no
  reachable Classic value becomes invalid. (Tradeoff, same as weight: a sub-100 cm Classic-wheel spin
  now reads as invalid.)
- **Keyboard `Done` key added now** (Decision 17a, revisited at this two-field entry): a
  `ToolbarItem(placement: .keyboard)` "Done" over a `@FocusState` dismiss. The first field to carry
  one; intended as the shared pattern to back-port to the age / weight entries later.
- **Feet & inches remainder = 0–11** (Decision 12 analog): a 12+ inches entry rejects-and-nags rather
  than carrying into the feet box. No separate feet cap — the cm range catches any feet value beyond
  the ceiling (unlike weight's stones-40 cap, which sat below the ceiling).

### Deltas from the weight plan

- Two-field case is **feet & inches** (feet + an inches-remainder 0–11), not stones & pounds (0–13).
- Converter is `LengthConverter` (`toCentimeters(feet:inches:)`, `toFeet`, `toRemainingInches`), not
  `WeightConvertor`.
- In-field suffixes are short: `cm` / `in` (single field), `ft` + `in` (feet & inches).
- `LengthConverter` / `displayLength` **untouched** — integer entry means no round-vs-floor concern,
  exactly as Decision 17b kept weight's converter alone.

### Files

| File | Change |
|------|--------|
| `TDEE/ViewSections/HeightNewSectionView.swift` | **New** — inline no-panel shell (copy `WeightNewSectionView`); composes the switcher + value slots; a11y line-drop; `UILabelValidationMessage`. |
| `TDEE/ViewsValueEditors/UIHeightUomMenuButtonView.swift` | **New** — neutral "Units" menu binding `$model.heightUom` (copy `UIWeightUomMenuButtonView`); full-width `UISegmentUomLengthView` reused at a11y sizes. |
| `TDEE/ViewsValueEditors/UIHeightTextFieldEntry.swift` | **New** — 1 field for cm/inches, 2 for feet & inches, in-field UoM suffix, per-field buffers, `.numberPad`, a `@FocusState` **Done** key; drives `HeightEntry`. |
| `TDEEShared/Models/ProfileViewModel/HeightEntry.swift` | **New** — pure `(OptionLength, fields) → .ok / .empty / .outOfRange / .unparseable`; commits cm only on a complete in-range entry (copy `WeightEntry`). |
| `TDEEShared/Config/MetricRanges.swift` | **Change** — add `height: ClosedRange<Double>` = `100...272` cm. |
| `TDEEShared/Models/ProfileViewModel/ProfileViewModelValidation.swift` | **Change** — `isHeightValid` → `MetricRanges.height.contains(height)`. |
| `TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift` | **Change** — the `height == 0` check → range-based, kept in sync with `isHeightValid`. |
| `TDEEShared/Utilities/LengthConverter.swift` + `displayLength.swift` | **Not touched** — integer entry means the New control displays like the Classic. |
| `TDEE/Pages/MainPage/MainSectionProfileInput.swift` | **Change** — `heightSection` reads **both** `.heightUom` and `.height`; any-"New" routes to `HeightNewSectionView`, all-Classic keeps the expand/collapse wheel (mirror `weightSection`). |
| `TDEETests/…/HeightEntryTests.swift` | **New** — validator + `MetricRanges.height` + two-gates-agree tests (copy `WeightEntryTests`). |

**Reused as-is:** `WeightNewSectionView` / `AgeNewSectionView` (shell), `UISegmentUomLengthView`
(a11y segmented), `UIWheelPickerHeightView` (Classic value), `UITextPickerLabel` (UoM voice),
`UILabelValidationMessage` (error), `LengthConverter.toCentimeters(feet:inches:)` (exact commit).
**Do NOT modify without approval:** `UISegmentUomLengthView`, `UIWheelPickerHeightView`,
`SectionEditorHeight` (the Classic path).

### Testing checklist

- [x] `HeightEntry.validate` — valid cm / inches / feet&inches, empty, out-of-range, unparseable,
      decimal-unparseable, remainder 12+ reject, feet beyond range.
- [x] `MetricRanges.height` contains / not-contains.
- [x] **Both gates** (`isHeightValid` *and* `validateForCalculation()`) reflect the range — an
      out-of-range or zero height hides results **and** blocks calc; `WeightEntryTests` still green.
- [ ] `Done` key dismisses the keyboard — **manual**.
- [ ] Manual (iPhone compact): menu switcher, 1-field cm/in, 2-field feet&inches, error messages.
- [ ] Manual (iPad regular + accessibility): full-width segmented switcher; feet fields stack.

---

## Activity Level pass (input #9) — built (Done, 2026-10-20)

Activity level is the lightest pass: a single categorical input over one model field — no UoM switcher,
no two-field case, and no range / zero gate (an activity level is always valid). So it needs none of the
weight / height machinery: no `MetricRanges` entry, no pure validator, no two-gate move, no converter.

### Decisions (this pass)

- **Neutral menu button** (owner-chosen): a `Menu` labelled "Activity Level", compact / regular; lists
  all 9 `ActivityLevel` cases and rebinds `model.activityLevel`. Mirrors the neutral UoM menu button
  (Decision 10). At accessibility sizes it drops to its own full-width line (the house a11y pattern).
- **No validation / no gates:** activity level is categorical — no `MetricRanges`, no validator, no
  `validateForCalculation()` change. The closed label is neutral ("Activity Level"); the current pick
  shows inside the open menu. Owner-verified and happy with the neutral closed label as the final form
  (2026-10-20) — surfacing the current pick in the *closed* label was considered and deferred.

### Files

| File | Change |
|------|--------|
| `TDEE/ViewsValueEditors/UIActivityLevelMenuButtonView.swift` | **New** — neutral `Menu` over `ActivityLevel.allCases`, rebinds `model.activityLevel` (mirrors the UoM menu buttons). |
| `TDEE/ViewSections/ActivityLevelNewSectionView.swift` | **New** — inline no-panel shell (copy `GenderNewSectionView`); the menu in the header, a11y line-drop. |
| `TDEE/Pages/MainPage/MainSectionProfileInput.swift` | **Change** — `activityLevelSection` `.new` case routes to `ActivityLevelNewSectionView`. |

**Reused as-is:** `GenderNewSectionView` (shell / a11y pattern), the neutral UoM menu button shape,
`InputID.activityLevel` / `InputMethodView` (the toggle already existed — no presenter change).
**Do NOT modify without approval:** `UIWheelPickerActivityLevelView`, `SectionEditorActivityLevel`,
`ActivityLevelClassicSectionView` (the Classic path).

### Testing checklist

- [x] `TDEE` builds for the iOS simulator (`** BUILD SUCCEEDED **`, no compile errors).
- [x] Full `TDEETests` suite passes unchanged — there is no validator type to test (categorical input).
- [x] Manual (iPhone compact): the menu lists all 9 levels; a selection rebinds `model.activityLevel` —
      owner-verified 2026-10-20.
- [x] Manual (iPad regular + accessibility): the menu drops to a full-width line — owner-verified
      2026-10-20.

---

## Body Fat pass (inputs #7 / #8) — built (Done, 2026-10-20)

Body fat is the story's most involved pass: two inputs over one section, the first **decimal** entry,
a **show/hide gate** between them, and an **asymmetric** range gate. It is one composing section like
weight / height (Decision 11), but the two pieces relate by *gate* (Omit/Estimate → no % field), not
unit re-derivation, and the range is new to the results gate. Three owner decisions (2026-10-20) close
the design: a **single 1-dp `%` field** (the first decimal entry), a **method-gated** addition to the
results gate, and the range extracted to **`MetricRanges`**. The three Classic controls
(`UISegmentBodyFatCalcMethodView`, `UIWheelPickerBodyFatView`, `SectionEditorBodyFatPercentage`) stay
**untouched**.

> **Status: built (Done, 2026-10-20)** — decisions 18–21 are locked and implemented. `BodyFatPercentageEntryTests`
> pass and the full `TDEETests` suite is green on iPhone 17 Pro Max / iOS 27 (`** TEST SUCCEEDED **`);
> the pre-existing `ProfileViewModelValidationTests` body-fat cases stay green.

### Decisions (this pass)

- **Composition — gated two-slot section** (#18, Decision 11 analog): `BodyFatPercentageNewSectionView`
  is an inline no-panel shell (copy `WeightNewSectionView`) composing two slots that each honor their
  own Classic/New toggle over the shared model:
  - **Method slot** (#8, `.bodyFatMethod`): `.new` → a neutral menu button; `.classic` → the segmented
    `UISegmentBodyFatCalcMethodView` reused verbatim (and at accessibility sizes).
  - **Value slot** (#7, `.bodyFatPercentage`): `.new` → a new `%` text entry; `.classic` → the wheel
    `UIWheelPickerBodyFatView` reused. **Shown only when `bodyFatPercentageMethod == .manualEntry`** —
    the gate, the one element with no precedent in the prior passes.
  - The New section gates the % field on `bodyFatPercentageMethod == .manualEntry` **directly**, not via
    `bodyFatPercentageShowManualEntry` — that flag is the Classic expanding-panel's open-state and the
    New section uses no `UILayoutExpandingPanel`, so the flag (Classic-only) is left alone. No model
    change.
- **Method control** (#19, Decision 10 analog): a neutral `UIBodyFatMethodMenuButtonView` (copy
  `UIActivityLevelMenuButtonView`) in compact / regular — closed label **"Method"**, listing
  `BodyFatOption.allCases` and rebinding `model.bodyFatPercentageMethod`, with the a11y line-drop; the
  segmented `UISegmentBodyFatCalcMethodView` is reused verbatim at accessibility sizes and for the
  Classic toggle. One control, two presentations.
- **Decimal entry** (#20, first decimal in the story): a **single `.decimalPad` field** with an in-field
  `%` suffix (`| 15.7 % |`, reusing `UITextPickerLabel`'s voice), one `@State` buffer, a `@FocusState`
  **`Done`** key (the height pattern), and **round-to-1-dp on commit** to match the Classic's integer+
  decimal wheels (`value = integer + decimal/10`). The integer `.numberPad` simplification (Decision 16)
  does **not** apply here. A pure `BodyFatPercentageEntry` maps `(text) → .ok(Double) / .empty /
  .outOfRange / .unparseable`, committing the rounded value only on a complete, in-range entry.
- **Range — single authority, method-gated in the results gate** (#21, Decision 14 analog with a twist):
  extract `MetricRanges.bodyFatPercentage = 5...50` from the hard-coded `5`/`50` in
  `CalculationValidatePerson.swift:25`; both `validateForCalculation()` and the entry read it. Unlike
  weight / height, the results gate `isValid`/`hasError` **starts composing body fat**, but **gated on
  the method**: a new `isBodyFatValid` is `MetricRanges.bodyFatPercentage.contains(bodyFatPercentage)`
  when `bodyFatPercentageMethod == .manualEntry`, else `true`. An out-of-range manual-entry body fat
  hides the results *and* blocks the calc pre-check; Omit/Estimate are never tripped — their default
  `bodyFatPercentage` (`0.0`) is out of 5–50, so an *ungated* check would flag every Omit/Estimate
  profile. The range thus moves to both gates, but the results-gate composition is conditioned on the
  method.

### Deltas from the weight / height passes

- **Gate, not unit switch** — the two slots relate by *show/hide* (method → % field visible), so the
  value slot is gated on the method rather than re-derived from a shared unit model.
- **Decimal** — the first `.decimalPad` entry; round-to-1-dp replaces the integer `.numberPad` commit.
- **Asymmetric gate** — the results `isValid`/`hasError` composes body fat, **conditioned on
  `.manualEntry`**, whereas weight / height's gates compose unconditionally.

### Files

| File | Change |
|------|--------|
| `TDEE/ViewSections/BodyFatPercentageNewSectionView.swift` | **New** — inline no-panel section (copy `WeightNewSectionView`); composes the method slot + a method-gated % value slot; a11y line-drop; one `UILabelValidationMessage`. Gates the % field on `bodyFatPercentageMethod == .manualEntry`. |
| `TDEE/ViewsValueEditors/UIBodyFatMethodMenuButtonView.swift` | **New** — neutral "Method" menu over `BodyFatOption.allCases`, rebinds `model.bodyFatPercentageMethod` (copy `UIActivityLevelMenuButtonView`); the segmented `UISegmentBodyFatCalcMethodView` reused at a11y sizes / for the Classic toggle. |
| `TDEE/ViewsValueEditors/UIBodyFatPercentageTextFieldEntry.swift` | **New** — single `.decimalPad` field, in-field `%` suffix, per-field buffer, **round-to-1-dp** commit, a `@FocusState` **`Done`** key; drives `BodyFatPercentageEntry`. Rendered by the section only for `.manualEntry`. |
| `TDEEShared/Models/ProfileViewModel/BodyFatPercentageEntry.swift` | **New** — pure `(text) → .ok(Double) / .empty / .outOfRange / .unparseable`; parses a decimal, rounds to 1 dp, commits only a complete in-range value (copy `WeightEntry` / `HeightEntry`). |
| `TDEEShared/Config/MetricRanges.swift` | **Change** — add `bodyFatPercentage: ClosedRange<Double>` = `5...50`. |
| `TDEEShared/Models/ProfileViewModel/ProfileViewModelValidation.swift` | **Change** — add method-gated `isBodyFatValid` and compose it into `isValid` / `hasError`. |
| `TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift` | **Change** — the `.manualEntry` range check reads `MetricRanges.bodyFatPercentage` (replacing the hard-coded `5`/`50`). |
| `TDEE/Pages/MainPage/MainSectionProfileInput.swift` | **Change** — `bodyFatPercentageSection` reads **both** `.bodyFatMethod` and `.bodyFatPercentage`; any "New" routes to `BodyFatPercentageNewSectionView`, all-Classic keeps the expand/collapse wheel (mirror `weightSection` / `heightSection`). |
| `TDEETests/…/BodyFatPercentageEntryTests.swift` | **New** — validator + `MetricRanges.bodyFatPercentage` + both-gates-agree tests, incl. the method-gated results gate (copy `WeightEntryTests` / `HeightEntryTests`). |

**Reused as-is:** `WeightNewSectionView` / `ActivityLevelNewSectionView` (shell + menu pattern),
`UISegmentBodyFatCalcMethodView` (a11y segmented / Classic method), `UIWheelPickerBodyFatView`
(Classic value), `UILabelValidationMessage` (error), `UITextPickerLabel` (the `%` suffix voice).
**Do NOT modify without approval:** `UISegmentBodyFatCalcMethodView`, `UIWheelPickerBodyFatView`,
`SectionEditorBodyFatPercentage` (the Classic path).

### Testing checklist

- [x] `BodyFatPercentageEntry.validate` — valid `5.0` / `15.7` / `50.0`; round-to-1-dp (`15.75` →
      `15.8`); a trailing dot reads as the whole number (`"15."` → `15.0`); empty; out-of-range
      (`4.9`, `50.1`); unparseable (multiple dots `"15.7.2"`, a negative, non-numeric `"abc"`).
- [x] `MetricRanges.bodyFatPercentage` contains / not-contains.
- [x] **Both gates, method-gated** — `validateForCalculation()` *and* `isValid`/`hasError` reflect the
      range; an out-of-range body fat with `.manualEntry` blocks calc **and** hides results;
      `.omit` / `.estimate` are **never** tripped (default `0.0` stays valid).
- [x] `TDEE` builds; full `TDEETests` suite passes on iPhone 17 Pro Max / iOS 27 (`** TEST SUCCEEDED **`).
- [ ] Manual (iPhone compact): the "Method" menu; the % field appears only for Manual Entry; switching
      away hides it and clears the buffer/error; error messages — **manual**.
- [ ] Manual (iPad regular + accessibility): the segmented method selector full-width; the % field on
      its own line — **manual**.

### Risks

- **Method-gating the results gate** — the new `isBodyFatValid` must be conditioned on `.manualEntry`,
  or the default `0.0` (Omit/Estimate) trips `isValid` and hides results for every non-manual profile.
- **Two gates drifting** — the range must land in `validateForCalculation()` *and* `isBodyFatValid` in
  the same change, both reading `MetricRanges.bodyFatPercentage`, or the results view and the calc
  pre-check disagree.
- **Decimal edge** — the `.decimalPad` parse must reject malformed input (`"15."`, multiple dots) as
  `.unparseable` and round to 1 dp so the committed value matches the Classic's integer+decimal wheels;
  parse with a fixed decimal format, not the raw keyboard locale.
- **Gated slot** — switching the method away from Manual Entry must hide the % field and clear its
  buffer/error with no model change; the gate is read from `bodyFatPercentageMethod` directly.
