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
