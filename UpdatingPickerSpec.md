# UpdatingPickerSpec — The Classic Height Picker

**Status:** Reference / in progress
**Last updated:** 2026-10-29
**Branch:** `theme-new`
**Owner:** David Berry

A one-stop reference for the **Classic height input control** so future work on it doesn't require
re-investigating the code. It documents the full render path, the data model, the unit-conversion and
validation rules, the themed/plain split, accessibility, and the New sibling for contrast — then the
*progress* sections at the bottom (Goal, Open questions, Decisions, Progress) are where we track the
amendment itself.

---

## 1. Scope

**In scope:** the Classic height control — the UoM switcher + the multi-wheel picker — and the Orange
theme's dressing of it.

**Out of scope:** every other input, the New-style height control (documented here only for contrast),
the Orange palette's non-picker fields, and the watch app (the watch keeps its own standalone store —
see project memory; it has no shared height picker).

## 2. The two axes don't collide — keep them separate

"Classic" and "Orange" are **orthogonal**, and the word "theme" is used for both:

| Axis | Values | What it does | Lives in |
|---|---|---|---|
| **Input style** | `classic` / `new` (per input) | *which* control renders the height input | `InputStyleManager`, `InputID.height` / `.heightUom` |
| **Colour theme** | Default, **Orange**, Clouds, Turquoise, … | *how* the active control is dressed | `Theme` / `ColorPalette` |

- **Classic** = today's control: a UoM switcher + a `.pickerStyle(.wheel)` wheel. It is the **default**
  when no preference is stored (`InputStyleManager.style(for:)` returns `.classic`).
- **New** = the redesigned inline text field (`UIHeightTextFieldEntry`).
- **Orange** is a *colour* theme, not an input style. It just dresses whichever control renders: the
  wheel gets a light-coral panel, a forced light appearance, and (on the *single-wheel* pickers only) a
  coral selection band.

> "Amend the Classic height picker on Orange" = edit the Classic wheel and its Orange dressing, **not**
> the New text field and **not** Orange's other fields.

### The section factory (what picks Classic vs New)

`MainSectionProfileInput.heightSection` (`TDEE/Pages/MainPage/MainSectionProfileInput.swift:61-74`)
reads **both** height toggles and routes:

- `(heightUom: .classic, height: .classic)` → `HeightClassicSectionView` (this control).
- **Any** `.new` toggle → `HeightNewSectionView` (the composing New section).

So "the Classic height picker shows" requires **both** `heightUom` and `height` to be `.classic`.

## 3. The control, top-down (render path)

```
MainSectionProfileInput            TDEE/Pages/MainPage/MainSectionProfileInput.swift:61
  └─ HeightClassicSectionView      TDEE/ViewSections/HeightClassicSectionView.swift
       └─ UILayoutSectionView      TDEE/ViewsLayouts/UILayoutSectionView.swift   (expand/collapse shell)
            ├─ UISectionSummaryValueHeight   TDEE/ViewsSectionSummaryValues/UISectionSummaryValueHeight.swift   (collapsed summary)
            └─ SectionEditorHeight           TDEE/ViewSectionEditors/SectionEditorHeight.swift   (editor, when open)
                 ├─ UISegmentUomLengthView   TDEE/ViewsValueEditors/Height/UISegmentUomLengthView.swift   ⚠ DO NOT MODIFY
                 └─ UIWheelHeightThemed | UIWheelHeightPlain
                      TDEE/ViewsValueEditors/Height/UIWheelHeightThemed.swift  (Orange: panel + light)
                      TDEE/ViewsValueEditors/Height/UIWheelHeightPlain.swift   (the 3-wheel picker)
```

- **`HeightClassicSectionView`** (`:15-41`) wraps everything in `UILayoutSectionView` with `title:
  "Height"`, `icon: .height`, `isExpanded: $sectionManager.heightIsExpanded`, `sectionId:
  "sectionHeight"`, and an inline `validationText`.
- **`SectionEditorHeight`** (`:21-31`) is the editor: the UoM segment on top, then the wheel —
  `UIWheelHeightThemed` when `palette.isPickerThemed` else `UIWheelHeightPlain`.
- The **New section** (`HeightNewSectionView`, `TDEE/ViewSections/HeightNewSectionView.swift`) is a
  *different* layout — no expand/collapse, the control sits inline in the header — and it composes the
  switcher + value slots independently per toggle.

## 4. Data model — `height` is stored in **centimetres**

The model's single source of truth is `model.height` (**a `Double` in cm**), plus `model.heightUom`
(an `OptionLength`):

- `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift:69-79` — `heightUom: OptionLength`
  (default `.centimeters`) and `height: Double` (default `AppConfig.shared.profileDefaults.height`);
  both `didSet { triggerSave() }` (throttled persistence).
- **⚠ Gotcha:** the doc comments say "in the current unit of measure", but that is **stale** — the
  wheels always read/write cm. `UIWheelHeightPlain` reads `value` as cm (`Int(round(value))`) and the
  cm/inches/feet conversions all funnel back to cm. Treat `model.height` as **cm, always**.
- Persistence: `TDEEShared/Models/SwiftData/Profile.swift:17,20-25` stores `height: Double` and
  `heightUomRaw: Int` (mapped to/from `OptionLength` via `ProfileMapper`).

### The UoM enum

`TDEEShared/Enums/OptionLength.swift:8-12`:
```swift
public enum OptionLength: Int, CaseIterable {
    case centimeters = 0, inches = 1, feetAndInches = 2
}
```
- `displayName` → "Cm" / "Inches" / "Feet & Inches" (short, labels the a11y-size segmented control).
- `fullName` → "Centimeters" / "Inches" / "Feet & Inches" (spelled out, for the New menu button).

## 5. The Classic wheel picker — `UIWheelHeightPlain`

`TDEE/ViewsValueEditors/Height/UIWheelHeightPlain.swift` is a **multi-wheel** picker: three
`.pickerStyle(.wheel)` controls stacked in a `ZStack`, only one opaque + hittable at a time, cross-faded
on a UoM switch.

### The three wheels (`:158-215`)

| Wheel | `@State` | Options | Accessibility id | Label offset x |
|---|---|---|---|---|
| Centimeters (`:160-172`) | `valueCm` | `0...272` | `heightCmWheel` | 60 |
| Inches (`:174-187`) | `valueInches` | `0...107` | `heightInchesWheel` | 40 |
| Feet & Inches (`:189-215`) | `valueFeet` + `valueFeetInches` | `0...8` + `0...11` | `heightFeetWheel`, `heightFeetInchesWheel` | 36 + 36 |

Each wheel is a `Picker(.wheel)` of `Text("\(value)").tag(value)` with a `UITextPickerLabel` suffix
(`centimeters` / `inches` / `feet` / `inches`). The labels are `UITextPickerLabel` (`TDEE/ViewsLabels/UITextPickerLabel.swift`):
`footnote`, `palette.textSecondary`, `allowsHitTesting(false)`, positioned by the magic `offset(x:)`
values above.

### Cross-fade + state (`:56-102`, constants `:29-48`)

- A `ZStack` of all three, each toggled by `opacity` (1/0), `offset(y:)` (0 / 24), `scaleEffect`
  (1.0 / 0.98), `allowsHitTesting` — `.frame(height: 150)`, `.easeInOut(0.30)` on `unitOfMeasure`.
- **`onAppear`** → `initialiseValues()`: seed `valueCm = round(model.height)`, then derive
  `valueInches` / `valueFeet` / `valueFeetInches` from it.
- **`onChange(unitOfMeasure)`** → `syncStateFromPreviousUnit(oldMeasure:)`: re-derive the *other*
  wheels' state from the one just left, so a switch shows a consistent value.
- **`onChange(valueCm / valueInches / valueFeet / valueFeetInches)`** → `convertFrom…ToValue`:
  write the **cm** back to `model.height`. Each is guarded by the *current* `unitOfMeasure`, so only
  the active wheel's change commits.

### ⚠ The "re-derive display, never mutate the model" contract

Switching UoM **must not** change `model.height` — only re-derives the on-screen numbers. This is the
load-bearing invariant (Decision 13): a unit switch is a display change, not a value change.

### ⚠ Rounding is asymmetric (watch for round-trip drift)

`TDEEShared/Utilities/LengthConverter.swift`:
- `toInches(cm)` **rounds** (`Int(round(…))`, factor `0.3937007874`).
- `toCentimetersInt(inches)` **floors** (`Int(floor(…))`, factor `2.54`).

So a `cm → inches → cm` round-trip can drift by ±1 cm (round out, floor back). `toCentimeters(Double)`
keeps the Double (no rounding) and is what the commit path uses, so the *stored* value is exact; the
drift only shows in the *inches* display. Flag this before any "fix" to the sync logic.

## 6. Themed vs Plain — per-wheel panels

`UIWheelHeightThemed` (`TDEE/ViewsValueEditors/Height/UIWheelHeightThemed.swift:19-30`) feeds the
palette's panel dressing into `UIWheelHeightPlain`, which now insets **each wheel into its own
rounded-rect panel** (a `nil`-default width, so non-theming themes see no panel):
```swift
UIWheelHeightPlain(
    value:unitOfMeasure:
    pickerBackground: palette.pickerBackground,
    pickerPanelWidth: palette.pickerPanelWidth,        // fixed width per wheel (Orange: 110)
    pickerLabelOffsetX: palette.pickerLabelOffsetX,     // caption offset (Orange: 72)
    pickerWheelSpacing: palette.pickerWheelSpacing       // gap between compound wheels (Orange: 56)
)
    .preferredColorScheme(palette.pickerColorScheme)
```
The panel moved from *around the whole group* to *around each wheel* (`pickerPanel(background:width:)`,
`Color+Theme.swift:75`), so the feet-&-inches wheels are two separate fields and each unit caption sits
as a sibling *outside* its panel. It is still **not** `UIThemedWheelPicker` — a bespoke multi-wheel
ZStack — so it can take a panel + forced appearance but **not** a themed selection band.

### `pickerPanel` (`TDEE/Constants/Color+Theme.swift:75`)
`RoundedRectangle(cornerRadius: 12)`, `Spacing.small` padding, and — crucially — a `.clipShape`, because
`UIPickerView` draws its wheel and band *beyond its own frame*. A `nil` background (every non-opting
theme) leaves the picker untouched. An optional `width` insets just the wheel, so a multi-wheel group
gets one panel per wheel.

### Orange's dressing (`TDEE/Models/Theme/DefaultThemes.swift:76-121`; fields in `Theme.swift:38-62`)
- `pickerBackground = lightCoral #F8D0C5` — a tint of the section coral, so the panel reads in-family.
- `pickerColorScheme = .light` — forces digits dark on the light panel.
- `pickerSelectionColor = coral #E8633F` — themed selection band (single-wheel pickers only; see below).
- `pickerPanelWidth = 110` — narrows each wheel into its own field (tunable).
- `pickerLabelOffsetX = 72` — shifts each unit caption outside the narrowed panel (tunable).
- `pickerWheelSpacing = 56` — the gap between the two feet-&-inches wheels, so the "feet" caption sits
  between them (tunable).
- `isPickerThemed` (`Theme.swift:60-62`) is `true` for Orange, so `SectionEditorHeight` renders
  `UIWheelHeightThemed`.

### ⚠ The selection band still stays system-grey on height
The themed band comes from `UIThemedWheelPicker` via KVC (`setSelectionIndicator:`, guarded,
`TDEE/ViewsValueEditors/UIThemedWheelPicker.swift:81-84`, `112-124`) — a single-wheel `UIPickerView`
wrapper used by the **single-wheel** pickers (Age, Activity). The height wheel is multi-wheel, so its
selection band stays the system's fixed grey capsule (per the note in
`UIWheelHeightThemed.swift:11-13`). The per-wheel *panel* is now done; the *band* is the remaining gap —
see §11.1.

## 7. The UoM switcher — `UISegmentUomLengthView`  ⚠ DO NOT MODIFY

`TDEE/ViewsValueEditors/Height/UISegmentUomLengthView.swift:8-13` carries a hard warning:
> *DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES. … `.pickerStyle(.segmented)` is intentional …
> DO NOT change to `.menu` … DO NOT remove any option cases … APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.*

It is a `.segmented` `Picker` over `OptionLength.allCases` (`displayName`), a11y id `heightUnitSelector`.
The **accessibility-size** variant reuses this same control full-width (`HeightNewSectionView.swift:72`).
Treat this file as frozen unless the owner approves in writing.

## 8. Validation, range, and the "two gates"

- **Shared authority:** `MetricRanges.height = 100...272` cm
  (`TDEEShared/Config/MetricRanges.swift:26`). 100 cm ≈ 3 ft 3 in (rejects accidental low entries);
  272 cm ≈ 8 ft 11 in matches the wheels' reach, so no reachable value becomes invalid.
- **Two gates that must agree** (Decision 14 analog):
  - `ProfileViewModel.isHeightValid` = `MetricRanges.height.contains(height)`
    (`ProfileViewModelValidation.swift:44-46`).
  - `CalculationValidatePerson.validateForCalculation()` appends `"Height"` when out of range
    (`TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift:19-20`), kept in sync with the
    above.
- **⚠ The Classic section's own message is looser than the gate.** `HeightClassicSectionView.swift:23`
  sets `validationText = "Please enter a valid Height"` only when `height.isNaN || height == 0` — it does
  **not** check 100–272. So a wheel scrolled to 50 cm (reachable: options are `0...272`) shows *no*
  message yet `isHeightValid` is false, hiding results. This inconsistency is worth noting in any
  amendment.

## 9. Accessibility & dynamic type

- **Identifiers:** `sectionHeight` (section), `heightUnitSelector` (segment), `heightCmWheel` /
  `heightInchesWheel` / `heightFeetWheel` / `heightFeetInchesWheel` (wheels).
- **Summary a11y labels** (`UISectionSummaryValueHeight.swift`): "Height major value/units" and
  "Height minor value/units", each with an `accessibilityValue`.
- **Dynamic type:** the Classic control has no dynamic-type-specific wheel layout; `UILayoutSectionView`
  handles a11y sizing by giving the summary its own full-width line at accessibility sizes
  (`UILayoutSectionView.swift:78-89`). The New section is the one that re-lays-out the switcher for a11y.
- **The `height` wheel is a `UIPickerView` (via SwiftUI `.wheel`)** — it reads digits in the system
  label colour and ignores `foregroundStyle`; Orange forces `.light` so they read on the coral panel.

## 10. The New sibling (for contrast) — `UIHeightTextFieldEntry`

`TDEE/ViewsValueEditors/Height/UIHeightTextFieldEntry.swift` is the redesigned control. Differences the
amendment should respect:
- **Buffer-and-commit:** each field keeps a local buffer; commits to `model.height` (cm) **only** when
  the pure validator `HeightEntry` reports a complete, in-range entry (`commit()`, `:98-118`).
- **`HeightEntry`** (`TDEEShared/Models/ProfileViewModel/HeightEntry.swift`) is a view-free validator:
  one field for cm/inches, two (feet + 0–11 remainder) for feet & inches; returns `.ok(cm:)` /
  `.empty` / `.outOfRange` / `.unparseable`. Reject-and-nag (Decision 12): an inches remainder ≥ 12
  nags "Inches must be 0–11"; other out-of-range reads "Height must be 100–272 cm".
- **Integer entry this pass** (`.numberPad`), matching the Classic's integer wheels.
- **Re-derive, never mutate:** a UoM switch re-derives the buffers from stored cm (`rederive()`,
  `:148-160`) — same invariant as the Classic wheel.
- **The keyboard Done key is screen-owned** by `UIMainView` (not this entry) to avoid duplicate Done
  buttons when the height/body-fat/calorie entries co-locate.

## 11. Known tensions / gotchas (candidates for the amendment)

1. **Multi-wheel selection band (§6) — panel done, band open.** Each wheel now has its own panel
   (decision 2026-10-29). The themed *selection band* still can't reach a multi-wheel group; on Orange
   the band stays system-grey while Age/Activity get coral. Extending the band (wrap each height wheel in
   `UIThemedWheelPicker`, or push the KVC band onto the group) is the remaining candidate.
2. **Classic section message looser than the gate (§8).** The 0/NaN check vs the 100–272 range.
3. **Wheel can reach out-of-range values.** `optionsCm = 0...272` lets the wheel sit at 0–99 cm, which
   `isHeightValid` rejects with no visible message on the Classic path.
4. **Asymmetric rounding (§5).** `toInches` rounds, `toCentimetersInt` floors — round-trip drift.
5. **`UISegmentUomLengthView` is frozen (§7).** Any switcher change needs owner approval.
6. **Stale model comment (§4).** "height in the current unit of measure" — it's always cm.

## 12. Test coverage

- **`TDEETests/HeightEntryTests.swift`** — the New validator + the shared range: cm/inches/feet&inches
  valid/empty/out-of-range/unparseable, the 12-in remainder nag, feet-beyond-ceiling, `MetricRanges.height
  == 100...272`, and a two-gates-agree test (`isHeightValid` ⇄ `validateForCalculation()`).
- **No UI test for the Classic wheel itself** — the `UIWheelHeightPlain` cross-fade / sync logic is
  untested. If the amendment touches the wheel, add coverage for the sync/round-trip there.

## 13. File map (quick index)

| File | Role |
|---|---|
| `TDEE/Pages/MainPage/MainSectionProfileInput.swift:61` | Section factory; picks Classic vs New |
| `TDEE/ViewSections/HeightClassicSectionView.swift` | Classic section shell + inline validation message |
| `TDEE/ViewSections/HeightNewSectionView.swift` | New composing section (inline, no expand) |
| `TDEE/ViewSectionEditors/SectionEditorHeight.swift` | Classic editor: segment + themed/plain wheel |
| `TDEE/ViewsValueEditors/Height/UISegmentUomLengthView.swift` | UoM switcher ⚠ frozen |
| `TDEE/ViewsValueEditors/Height/UIWheelHeightPlain.swift` | The 3-wheel picker (cross-fade + sync) |
| `TDEE/ViewsValueEditors/Height/UIWheelHeightThemed.swift` | Panel + forced appearance (Orange) |
| `TDEE/ViewsValueEditors/Height/UIHeightTextFieldEntry.swift` | New text-field entry (contrast) |
| `TDEE/ViewsValueEditors/UIThemedWheelPicker.swift` | Generic single-wheel + themed band (KVC) |
| `TDEE/Constants/Color+Theme.swift:75` | `pickerPanel` modifier (fill + clip) |
| `TDEE/ViewsLabels/UITextPickerLabel.swift` | Wheel suffix label |
| `TDEE/ViewsSectionSummaryValues/UISectionSummaryValueHeight.swift` | Collapsed summary value |
| `TDEE/ViewsLayouts/UILayoutSectionView.swift` | Expand/collapse shell + a11y layout |
| `TDEEShared/Enums/OptionLength.swift` | The UoM enum |
| `TDEEShared/Utilities/LengthConverter.swift` | cm/inches/feet conversion |
| `TDEEShared/Utilities/displayLength.swift` | cm → display major/minor strings |
| `TDEEShared/Config/MetricRanges.swift:26` | The 100…272 cm authority |
| `TDEEShared/Models/ProfileViewModel/HeightEntry.swift` | New validator (view-free) |
| `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift:69` | `height` (cm) + `heightUom` |
| `TDEEShared/Models/ProfileViewModel/ProfileViewModelValidation.swift:44` | `isHeightValid` |
| `TDEEShared/Calculations/Extensions/CalculationValidatePerson.swift:19` | Second gate |
| `TDEE/Models/Theme/DefaultThemes.swift:76` | Orange palette |
| `TDEE/Models/Theme/Theme.swift:38` | Picker palette fields + `isPickerThemed` |
| `TDEE/Models/InputMethod/InputStyleManager.swift` | Per-input Classic/New store |
| `TDEETests/HeightEntryTests.swift` | Validator + range tests |

## 14. Goal — what we want the amendment to achieve

**On Orange, each wheel of the height picker sits in its own light-coral field, and the "feet"/"inches"
captions sit *outside* their field on the section background — so feet & inches read as two separate
pickers, not one wide field.** Every other theme is untouched (`nil`-default palette fields).

- [x] Desired end state: per-wheel panel + caption outside it, Orange-only.
- [x] Why it's worth doing: one wide field made the two feet-&-inches wheels read as a single control.
- [ ] Acceptance test / how we'll know it's right: build succeeds; on Orange the feet & inches wheels
      show two separate panels with their captions outside; cm/inches show one panel each; other themes
      unchanged. *(Visual check pending in Xcode — `pickerPanelWidth`/`pickerLabelOffsetX` are the two
      tunable numbers.)*
- [x] UoM modes: all three — the caption offset applies per wheel; feet+inches is the visible case.

## 15. Open questions / to decide

- [ ] Do we extend the themed selection band to the multi-wheel height picker, or keep the system capsule
      on Orange? (§11.1)
- [ ] Do we tighten the Classic section's `validationText` to the 100–272 range to match `isHeightValid`?
      (§11.2)
- [ ] If the wheel touches the sync/round-trip, what test coverage do we add? (§12)
- [ ] Is `UISegmentUomLengthView` truly frozen, or does this amendment need its approval path? (§11.5)

## 16. Decisions log

> Newest on top. Each entry: date, decision, rationale, and any option rejected.

| Date | Decision | Rationale | Rejected option(s) |
|---|---|---|---|
| 2026-10-29 | **Per-wheel panel** — move `pickerPanel` from around the whole group onto each wheel | One group panel made the feet-&-inches wheels read as a single field | — |
| 2026-10-29 | **Narrow panel + caption outside, both theme-driven** (`pickerPanelWidth` + `pickerLabelOffsetX`, `nil` default) | Chosen over "offset-x only" (panel stays wide) and "width only" (caption can't clear it); both knobs together get the caption outside a narrowed field, and `nil` defaults keep every other theme identical | Offset-x only; width only |

## 17. Progress

> A task list we tick off as work lands. Cross-reference the commit/PR that closes each item.

- [x] Per-wheel panel: `pickerPanel` moved onto each wheel; `pickerPanel(background:width:)` (built, exit 0).
- [x] Caption outside: `pickerLabelOffsetX` shifts the caption; Orange sets `pickerPanelWidth: 110`, `pickerLabelOffsetX: 72`.
- [ ] Visual confirm in Xcode — tune `pickerPanelWidth`/`pickerLabelOffsetX` if a caption overlaps the
      next wheel in feet & inches.
- [ ] Themed selection band for the multi-wheel group (§11.1) — next candidate.

## 18. References

- Story 023 (Input Method): `documentation/stories/story-023-input-method/{plan,story}.md`
- Story 018 (Themes): `documentation/stories/story-018-themes/palettes.md`
- `UI_RESTRICTIONS.md` — app-wide UI constraints
- Project memory: *Watch is standalone with local SwiftData* (the watch has no shared height picker).
