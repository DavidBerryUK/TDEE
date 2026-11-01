# UpdatingPickerSpec — The Classic Height Picker

**Status:** Reference / in progress
**Last updated:** 2026-10-31
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
  wheel gets a light-coral panel and a forced light appearance, so its digits read dark on the panel.

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
                      TDEE/ViewsValueEditors/Height/UIWheelHeightThemed.swift  (Orange: feeds the palette's picker fields)
                      TDEE/ViewsValueEditors/Height/UIWheelHeightPlain.swift   (cm/inches/feet+inches, 4 UIThemedWheelPicker wheels)
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

> **Current state (post-fix, 2026-10-31).** The renderer is a shared `heightWheel(_:selection:rows:)` builder
> that returns a **native** `.pickerStyle(.wheel)` by default and a `UIThemedWheelPicker` (a forced-appearance
> `UIPickerView`) when `forceAppearance` is set — so the **plain** control is the original native wheel and
> only the **themed** control (`UIWheelHeightThemed`) uses `UIThemedWheelPicker`. A native wheel's digit
> colour can't be forced by `foregroundStyle` *or* a wrapper's `.preferredColorScheme` (that's what broke the
> first cut) — the appearance must be forced on the `UIPickerView` itself. See §18.

`TDEE/ViewsValueEditors/Height/UIWheelHeightPlain.swift` is a **multi-wheel** picker: the cm, inches and
feet-&-inches modes stacked in a `ZStack` — four wheels (feet-&-inches is two), only one opaque + hittable
at a time, cross-faded on a UoM switch. Each wheel is built by a shared `heightWheel` renderer: a native
`.pickerStyle(.wheel)` by default, or a `UIThemedWheelPicker` (`TDEE/ViewsValueEditors/UIThemedWheelPicker.swift`,
a `UIPickerView` a theme can dress) when `forceAppearance` is set. The native wheel ignores `foregroundStyle`
and a wrapper's `.preferredColorScheme` does not force its digit colour, so the digit colour comes from the
`UIPickerView`'s forced appearance — only the themed control sets `forceAppearance`.

### The four wheels (via `heightWheel`, from `:206`)

| Wheel | `@State` | Options | Accessibility id | Caption x-offset (fallback) |
|---|---|---|---|---|
| Centimeters | `valueCm` | `0...272` | `heightCmWheel` | `pickerLabelOffsetX ?? 60` |
| Inches | `valueInches` | `0...107` | `heightInchesWheel` | `pickerLabelOffsetX ?? 40` |
| Feet | `valueFeet` | `0...8` | `heightFeetWheel` | `pickerFeetLabelOffsetX ?? pickerLabelOffsetX ?? 36` |
| Feet-inches | `valueFeetInches` | `0...11` | `heightFeetInchesWheel` | `pickerFeetInchesLabelOffsetX ?? pickerLabelOffsetX ?? 36` |

Each wheel is `heightWheel(label:selection:rows:)` — native `.pickerStyle(.wheel)`, or `UIThemedWheelPicker`
when `forceAppearance` — with a `UITextPickerLabel` suffix
(`centimeters` / `inches` / `feet` / `inches`). The labels are `UITextPickerLabel`
(`TDEE/ViewsLabels/UITextPickerLabel.swift`): `footnote`, `palette.textSecondary`,
`allowsHitTesting(false)`, positioned by the `offset(x:)` values above. The feet-&-inches wheels sit in an
`HStack` whose gap is `pickerWheelSpacing` (when set) so the "feet" caption can sit *between* them.

### Cross-fade + state (`:86-125`, constants `:52-72`)

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

## 6. Themed vs Plain — per-wheel panels + digit colour

`UIWheelHeightThemed` (`TDEE/ViewsValueEditors/Height/UIWheelHeightThemed.swift:19-37`) feeds the
palette's picker dressing into `UIWheelHeightPlain`, which insets **each wheel into its own rounded-rect
panel** and forces a light appearance so the digits read on it (a `nil`-default width/appearance, so
non-theming themes see no panel and keep the system digits):
```swift
UIWheelHeightPlain(
    value:unitOfMeasure:
    pickerBackground: palette.pickerBackground,        // panel fill (Orange: lightCoral #F8D0C5)
    pickerPanelWidth: palette.pickerPanelWidth,        // fixed width per wheel (Orange: 96)
    pickerLabelOffsetX: palette.pickerLabelOffsetX,     // cm/inches caption offset (Orange: 78)
    pickerFeetLabelOffsetX: palette.pickerFeetLabelOffsetX,        // "feet" caption (Orange: 74)
    pickerFeetInchesLabelOffsetX: palette.pickerFeetInchesLabelOffsetX, // "inches" caption (Orange: 82)
    pickerWheelSpacing: palette.pickerWheelSpacing,     // gap between compound wheels (Orange: 60)
    forceAppearance: palette.pickerColorScheme != nil   // render UIThemedWheelPicker so digits force dark
)
    .preferredColorScheme(palette.pickerColorScheme)
```
In the themed control each wheel is a `UIThemedWheelPicker` (a `UIPickerView` a theme can dress, via
`forceAppearance`), so a multi-unit layout *can*
now be themed. The panel moved from *around the whole group* to *around each wheel*
(`pickerPanel(background:width:)`, `Color+Theme.swift:75`), and the digit colour is forced via the
picker's appearance (`pickerColorScheme` → `overrideUserInterfaceStyle`), not `foregroundStyle`, which the
native `.wheel` ignores. The themed **selection band was removed** (see below) — every wheel now shows the
system's capsule.

### `pickerPanel` (`TDEE/Constants/Color+Theme.swift:75`)
`RoundedRectangle(cornerRadius: 12)`, `Spacing.small` padding, and — crucially — a `.clipShape`, because
`UIPickerView` draws its wheel *beyond its own frame*. A `nil` background (every non-opting theme) leaves
the picker untouched. An optional `width` insets just the wheel, so a multi-wheel group gets one panel per
wheel.

### Why the digit colour comes from `pickerColorScheme`, not a colour field
The wheel's digits are drawn by the underlying `UIPickerView` in the system label colour; a forced
`.light` appearance (set on the `UIPickerView` via `overrideUserInterfaceStyle` in
`UIThemedWheelPicker.applyTheme`) makes them render dark on the light-coral panel. An earlier attempt
coloured the digits with `foregroundStyle` + a `pickerText` palette field, but the native wheel ignores
`foregroundStyle` and a forced light appearance lost to the app's dark scheme — so that path was dead and
is gone. `pickerColorScheme` is the live knob.

### Orange's dressing (`TDEE/Models/Theme/DefaultThemes.swift:76-131`; fields in `Theme.swift:38-80`)
- `pickerBackground = lightCoral #F8D0C5` — a tint of the section coral, so the panel reads in-family.
- `pickerColorScheme = .light` — forces the picker's appearance light, so the digits read dark on the
  panel. This is the *live* digit-colour knob (not a `foregroundStyle`/`pickerText`).
- `pickerPanelWidth = 96` — narrows each wheel into its own field (tunable).
- `pickerLabelOffsetX = 78` — shifts the cm / inches captions to the **right** of their panel.
- `pickerFeetLabelOffsetX = 74`, `pickerFeetInchesLabelOffsetX = 82` — separate offsets for the "feet"
  (short) and "inches" (long) captions so they hold **equal gaps** from their panels; a single shared
  offset can't equalise a short and a long label. Fall back to `pickerLabelOffsetX` when a theme sets only
  the shared offset.
- `pickerWheelSpacing = 60` — the gap between the two feet-&-inches wheels, so the "feet" caption sits
  between them (tunable).
- `isPickerThemed` (`Theme.swift:78-80`) is `pickerBackground != nil || pickerColorScheme != nil`, so it
  is `true` for Orange and `SectionEditorHeight` renders `UIWheelHeightThemed`.

### ⚠ The themed selection band was removed (2026-10-31)
The band was a `UIPickerView` private-API hack — KVC `setSelectionIndicator:` (guarded so a missing key
degrades to the system capsule) wrapping a `ThemedSelectionIndicator` view, gated behind a `themedBand`
flag and a `pickerSelectionColor` palette field. It **never rendered** (true/false looked identical on
iOS 27), so the whole machinery — `themedBand`, `ThemedSelectionIndicator`, `applySelectionIndicator`, and
`pickerSelectionColor` — was removed as dead code. Every wheel now shows the system's fixed grey capsule.
`isPickerThemed` no longer tests a band field; the panel + forced appearance are enough to opt in.

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
- **Each `height` wheel is a `UIThemedWheelPicker` (a `UIPickerView`)** — the digits are drawn in the
  system label colour and ignore `foregroundStyle`; Orange forces a `.light` appearance
  (`pickerColorScheme`) so they render dark on the coral panel.

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

1. **Themed selection band — RESOLVED by removal (2026-10-31).** Each wheel has its own panel and a forced
   light appearance. The themed *selection band* (a `UIPickerView` KVC hack) never rendered, so it was
   removed rather than extended. Every wheel now shows the system's capsule; Age/Activity lost their
   themed band too. Revisit only if a real band API (or a working private key) becomes available.
2. **Classic section message looser than the gate (§8).** The 0/NaN check vs the 100–272 range.
3. **Wheel can reach out-of-range values.** `optionsCm = 0...272` lets the wheel sit at 0–99 cm, which
   `isHeightValid` rejects with no visible message on the Classic path.
4. **Asymmetric rounding (§5).** `toInches` rounds, `toCentimetersInt` floors — round-trip drift.
5. **`UISegmentUomLengthView` is frozen (§7).** Any switcher change needs owner approval.
6. **Stale model comment (§4).** "height in the current unit of measure" — it's always cm.
7. **⚠ REGRESSION → RESOLVED 2026-10-31 (§18): the *plain* height wheel was a `UIPickerView`, not the
   original native wheel.** Since `1c916dc`, `UIWheelHeightPlain` rendered *every* wheel through
   `UIThemedWheelPicker` (a `UIPickerView`), not the native `.pickerStyle(.wheel)` that `develop` — and
   Age's / Weight's *plain* siblings — use. On a non-Orange theme nothing sets `pickerPanelWidth`, so
   `pickerPanel` no-ops and each `UIPickerView` is width-unbounded and fills the section: the height section
   reads "too wide" and the right-pointing captions ("centimeters" +60, "inches" +40, feet/inches +36) sit
   off the right edge. **Resolved** by making the wheel native `.pickerStyle(.wheel)` by default
   (`forceAppearance: false`) and rendering `UIThemedWheelPicker` only for the themed control. A first cut
   that kept the native wheel + a wrapper `.preferredColorScheme` failed — the digit colour forces only via
   the `UIPickerView`'s `overrideUserInterfaceStyle` (see §18).
8. **Weight + body fat ported (2026-10-31).** `UIWheelWeightThemed/Plain` + `SectionEditorWeight` and
   `UIWheelBodyFatThemed/Plain` now mirror the height fix: `forceAppearance` + a shared wheel builder
   (`weightWheel` / `bodyFatWheel`) render each wheel as `UIThemedWheelPicker` (forced light appearance) when
   the theme opts in, so the digits read dark on the light panel — the bug the wrapper's `.preferredColorScheme`
   could never fix. Weight adds per-wheel `pickerPanel(background:width:)` + theme-driven caption offsets + a
   `.padding(.vertical, Spacing.large)` breath; its compound unit (stones & pounds) reuses the shared
   `pickerFeetLabelOffsetX` / `pickerFeetInchesLabelOffsetX` / `pickerWheelSpacing` knobs. Body fat is a single
   number (integer.decimal%), so it keeps ONE group panel and no side captions / breath — only the forced digit
   colour changes. **Watch:** body fat's inline "." and "%" use `palette.textSecondary` (white on Orange) and may
   wash out on the light panel; a panel-aware colour would be a follow-up.

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
| `TDEE/ViewSectionEditors/SectionEditorHeight.swift` | Classic editor: segment + themed/plain wheel; 16pt top/bottom breath around the wheel (in the editor, not the wheel view — §16) |
| `TDEE/ViewsValueEditors/Height/UISegmentUomLengthView.swift` | UoM switcher ⚠ frozen |
| `TDEE/ViewsValueEditors/Height/UIWheelHeightPlain.swift` | Multi-wheel picker; native `.pickerStyle(.wheel)` by default, `UIThemedWheelPicker` when `forceAppearance` (cross-fade + sync, one copy) |
| `TDEE/ViewsValueEditors/Height/UIWheelHeightThemed.swift` | Panel + forced appearance (Orange) |
| `TDEE/ViewsValueEditors/Height/UIHeightTextFieldEntry.swift` | New text-field entry (contrast) |
| `TDEE/ViewsValueEditors/UIThemedWheelPicker.swift` | Generic `UIPickerView` wheel; forces digit appearance via `pickerColorScheme` (no themed band — removed 2026-10-31) |
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
| `TDEE/Models/Theme/Theme.swift:38` | Picker palette fields + `isPickerThemed` (no `pickerSelectionColor` / `pickerText` — removed 2026-10-31) |
| `TDEE/Models/InputMethod/InputStyleManager.swift` | Per-input Classic/New store |
| `TDEETests/HeightEntryTests.swift` | Validator + range tests |

## 14. Goal — what we want the amendment to achieve

**On Orange, each wheel of the height picker sits in its own light-coral field, and the "feet"/"inches"
captions sit *outside* their field on the section background — so feet & inches read as two separate
pickers, not one wide field.** Every other theme is untouched (`nil`-default palette fields).

- [x] Desired end state: per-wheel panel + caption outside it, Orange-only.
- [x] Why it's worth doing: one wide field made the two feet-&-inches wheels read as a single control.
- [x] Acceptance test / how we'll know it's right: build succeeds; on Orange the feet & inches wheels
      show two separate panels with their captions outside; cm/inches show one panel each; other themes
      unchanged. *(Confirmed in Xcode.)*
- [x] UoM modes: all three — the caption offset applies per wheel; feet+inches is the visible case.
- [x] **Regression fix (§11.7 / §18):** on a non-Orange theme (e.g. Clouds) the section renders the
      *original native* `.pickerStyle(.wheel)` — same width as `develop`, captions in-bounds, no
      `UIPickerView` fill; Orange keeps its per-wheel panels + dark digits. *(Confirmed by the user.)*

## 15. Open questions / to decide

- [x] **Resolved 2026-10-31:** the themed selection band was removed as a no-op (it never rendered); every
      wheel shows the system capsule. (§11.1)
- [x] **Done 2026-10-31: fix the "too wide" plain wheel by restoring two controls (§11.7 / §18).**
      `UIWheelHeightPlain` is the *original native* `.pickerStyle(.wheel)` again (the "Original" control, via a
      shared `heightWheel` builder + a `forceAppearance` flag); `UIWheelHeightThemed` is the only one that
      dresses it, rendering `UIThemedWheelPicker` per wheel so the digit colour is forced on the `UIPickerView`.
      Rejected: constraining the `UIPickerView` width on the plain path, and a wrapper `.preferredColorScheme`
      (fails to force the digit colour). **Out of scope for this fix:** the `validationText` tightening, wheel
      test coverage, and the frozen-segment question below.
- [ ] Do we tighten the Classic section's `validationText` to the 100–272 range to match `isHeightValid`?
      (§11.2)
- [ ] If the wheel touches the sync/round-trip, what test coverage do we add? (§12)
- [ ] Is `UISegmentUomLengthView` truly frozen, or does this amendment need its approval path? (§11.5)

## 16. Decisions log

> Newest on top. Each entry: date, decision, rationale, and any option rejected.

| Date | Decision | Rationale | Rejected option(s) |
|---|---|---|---|
| 2026-10-31 | **Port the two-control fix to body fat** (`UIWheelBodyFatPlain/Themed`) — `forceAppearance` + a shared `bodyFatWheel` builder, so each wheel renders as `UIThemedWheelPicker` (forced light appearance) and the digits read dark on the light panel | Body fat's themed wheel was on the old whole-group panel + wrapper `.preferredColorScheme` shape — the same light-digit-on-panel bug. Body fat is a single number (integer.decimal%), so it keeps ONE group panel and no side captions / breath — only the forced digit colour changes | Per-wheel panels + caption offsets / breath (a single number reads as one field, not a compound split); a panel-aware colour for the inline "." and "%" (flagged as a follow-up in §11.8) |
| 2026-10-31 | **Port the two-control fix to weight** (`UIWheelWeightPlain/Themed` + `SectionEditorWeight`) — `forceAppearance` + a shared `weightWheel` builder, per-wheel `pickerPanel(background:width:)`, theme-driven caption offsets, and the `.padding(.vertical, Spacing.large)` container breath, mirroring height | Weight's themed wheel was on the old whole-group panel + wrapper `.preferredColorScheme` shape — the same light-digit-on-panel bug height's first cut had. The compound unit (stones & pounds) reuses the shared `pickerFeetLabelOffsetX` / `pickerFeetInchesLabelOffsetX` / `pickerWheelSpacing` knobs (`pickerWheelSpacing` is already documented as shared) | Add weight-specific `pickerStonesLabelOffsetX` / `pickerStonePoundsLabelOffsetX` fields (bigger change; the shared knobs already serve the compound unit) |
| 2026-10-31 | **16pt top/bottom breath around the height wheel's container** (`SectionEditorHeight`) — wrap the themed/plain wheel in a `Group` and give it `.padding(.vertical, Spacing.large)` | The height wheel sits tight under the unit segment; age's *standalone* picker row (`UIWheelAgeThemed/Plain`) breathes with `Spacing.large`. Same 16pt magnitude — age's is horizontal, height needs it vertical so the wheel isn't cramped under the segment | Put it in `UIWheelHeightPlain` (would touch the "APPROVAL REQUIRED" wheel/segment pairing **and** pad `HeightNewSectionView`'s wheel too); pad the whole `VStack` (would also push the segment up) |
| 2026-10-31 | **Restore two controls — native plain + forced-appearance themed (§11.7 / §18).** `UIWheelHeightPlain` is native `.pickerStyle(.wheel)` by default; `UIWheelHeightThemed` sets `forceAppearance: true` so each wheel renders as `UIThemedWheelPicker` (forced light appearance) + per-wheel `pickerPanel`; one `forceAppearance` flag keeps the cross-fade/sync a single copy | `1c916dc`'s "route all four wheels through `UIThemedWheelPicker`" made the *plain* control a width-unbounded `UIPickerView` that fills the section on every non-Orange theme ("too wide"). The digit colour needs the `UIPickerView`'s forced appearance, **not** a wrapper's `.preferredColorScheme` (that left Orange's digits light on the panel) | Constrain the `UIPickerView` width on the plain path (non-original look; can't do per-wheel panels); native plain + wrapper `.preferredColorScheme` (fails to force the digit colour) |
| 2026-10-31 | **Removed the themed selection band** (`a84bc82`) — dropped `themedBand`, `ThemedSelectionIndicator`, `applySelectionIndicator` and `pickerSelectionColor` | The band was a `UIPickerView` KVC hack that never rendered (true/false identical on iOS 27) — dead code; every wheel keeps the system capsule | Keep the dead band; gate it behind a flag |
| 2026-10-31 | **Theme-driven digit colour via forced appearance** (`1c916dc`, `07d77ce`) — the 4 height wheels render through `UIThemedWheelPicker`; digit colour comes from `pickerColorScheme` (forced `.light`), not `foregroundStyle`/`pickerText` | The native `.wheel` ignores `foregroundStyle` and loses a forced light appearance to the app's dark scheme, so the old `pickerText`/`.foregroundStyle` path was dead; `overrideUserInterfaceStyle` is what the age picker already used | `pickerText` + `foregroundStyle` (removed as dead) |
| 2026-10-31 | **Per-caption offsets** (`5784464`) — add `pickerFeetLabelOffsetX` / `pickerFeetInchesLabelOffsetX` (Orange 74 / 82); `pickerLabelOffsetX` 56 → 78 | A single shared `pickerLabelOffsetX` can't give "feet" (short) and "inches" (long) equal gaps from their panels; two knobs equalise them, `nil`-default so other themes are unchanged | One shared offset for all captions |
| 2026-10-29 | **Per-wheel panel** — move `pickerPanel` from around the whole group onto each wheel | One group panel made the feet-&-inches wheels read as a single field | — |
| 2026-10-29 | **Narrow panel + caption outside, both theme-driven** (`pickerPanelWidth` + `pickerLabelOffsetX`, `nil` default) | Chosen over "offset-x only" (panel stays wide) and "width only" (caption can't clear it); both knobs together get the caption outside a narrowed field, and `nil` defaults keep every other theme identical | Offset-x only; width only |

## 17. Progress

> A task list we tick off as work lands. Cross-reference the commit/PR that closes each item.

- [x] Per-wheel panel: `pickerPanel` moved onto each wheel; `pickerPanel(background:width:)`.
- [x] Caption outside: `pickerLabelOffsetX` shifts cm/inches; `pickerFeetLabelOffsetX` /
      `pickerFeetInchesLabelOffsetX` equalise the feet & inches gaps. Orange sets `pickerPanelWidth: 96`,
      `pickerLabelOffsetX: 78`, `pickerFeetLabelOffsetX: 74`, `pickerFeetInchesLabelOffsetX: 82`,
      `pickerWheelSpacing: 60`.
- [x] Theme-driven digit colour: the 4 wheels render through `UIThemedWheelPicker`; `pickerColorScheme:
      .light` forces dark digits on the panel. `pickerText` removed as dead.
- [x] Themed selection band: **removed** as a no-op (never rendered) — every wheel shows the system
      capsule. (§11.1)
- [x] Visual confirm in Xcode: feet & inches captions clear of their panels and digits dark on Orange
      (confirmed in the simulator; `5784464`, `1c916dc`).
- [x] **§18 fix:** `UIWheelHeightPlain`'s four wheels now render via a shared `heightWheel` builder — native
      `.pickerStyle(.wheel)` by default, `UIThemedWheelPicker` when `forceAppearance`; cross-fade/sync stays
      one copy. `UIWheelHeightThemed` passes `forceAppearance: palette.pickerColorScheme != nil`.
- [x] **§18 fix:** doc comments corrected in `UIWheelHeightPlain.swift` and `UIWheelHeightThemed.swift` — the
      digit colour is forced on the `UIPickerView` (`overrideUserInterfaceStyle`), not via a wrapper's
      `.preferredColorScheme`.
- [x] **§18 fix:** visual confirm — a non-Orange theme shows the original native wheel (section no longer too
      wide); Orange shows per-wheel panels with dark digits. (Confirmed by the user.)
- [x] **Container breath (§16):** `SectionEditorHeight` pads the wheel `.padding(.vertical, Spacing.large)` (16pt
      top/bottom), mirroring the age section's row padding. Kept in the editor — not `UIWheelHeightPlain` — so the
      "APPROVAL REQUIRED" wheel/segment pairing and `HeightNewSectionView`'s wheel stay untouched. (Pending visual
      confirm in Xcode — this box has no Xcode/simctl.)
- [x] **Weight port (§11.8):** `UIWheelWeightPlain/Themed` + `SectionEditorWeight` now mirror the height fix —
      `forceAppearance` + a shared `weightWheel` builder, per-wheel `pickerPanel(background:width:)`,
      theme-driven caption offsets, and the `.padding(.vertical, Spacing.large)` breath. The compound unit
      (stones & pounds) reuses the shared `pickerFeetLabelOffsetX` / `pickerFeetInchesLabelOffsetX` /
      `pickerWheelSpacing` knobs. (Pending visual confirm in Xcode.)
- [x] **Body fat port (§11.8):** `UIWheelBodyFatPlain/Themed` now mirror the height fix — `forceAppearance`
      + a shared `bodyFatWheel` builder force the digit appearance; one group panel (single number) is kept, so
      no per-wheel panels / captions / breath. Watch the inline "." / "%" colour (white `textSecondary` on the
      light panel). (Pending visual confirm in Xcode.)

## 18. Fix — two controls: native plain wheel + forced-appearance themed (landed)

**Problem (§11.7).** Since `1c916dc` ("route all four wheels through `UIThemedWheelPicker`"), the *plain*
height wheel is a `UIPickerView`, not the original native `.pickerStyle(.wheel)`. On any theme that doesn't
opt in (every theme but Orange), `pickerPanelWidth` is `nil`, so `pickerPanel` no-ops
(`Color+Theme.swift:78`, the `else { self }` branch) and each `UIPickerView` is width-unbounded — it fills
the section, and the right-pointing captions sit off the right edge. The section is "too wide." Orange is the
only theme that sets `pickerPanelWidth: 96`, so it's the only one that looks right.

**Approach: keep the two-control split the app already uses for Age/Weight, and let the *themed* control own
the digit colour.** The renderer is the only difference, so it's a single flag on the shared view — not a
duplicated cross-fade/sync:

| Control | Wheel renderer | Used when |
|---|---|---|
| `UIWheelHeightPlain` — *the Original* | native `Picker(...).pickerStyle(.wheel)`, undressed | `forceAppearance == false` — every non-Orange theme |
| `UIWheelHeightThemed` — *the Themed* | `UIThemedWheelPicker` (forced light appearance) + per-wheel `pickerPanel(background:width:)` | `forceAppearance == true` (Orange) |

**Why the digit colour needs `UIThemedWheelPicker`, not `.preferredColorScheme`.** A native
`.pickerStyle(.wheel)` ignores `foregroundStyle`, and a *wrapper's* `.preferredColorScheme(.light)` does
**not** force its digit colour — that's why the first cut (native plain + `.preferredColorScheme` on the
wrapper) left Orange's digits light on the light-coral panel. The colour must be forced on the underlying
`UIPickerView` itself via `overrideUserInterfaceStyle`, which is exactly what `UIThemedWheelPicker` does (from
the theme's `pickerColorScheme`). So the *themed* control renders `UIThemedWheelPicker` per wheel; the *plain*
control keeps the native wheel. `UIWheelWeightThemed` may share this latent bug — worth a check on Orange.

**How it stays a single copy.** `UIWheelHeightPlain` gained `var forceAppearance: Bool = false` and a shared
`heightWheel(label:selection:rows:)` builder that returns `UIThemedWheelPicker` when `forceAppearance`, else
the native `Picker(.pickerStyle(.wheel))`. All four wheel builders call `heightWheel`, so the cross-fade/sync
logic has one copy; the two controls differ only in the renderer. The per-wheel panel can't be applied from the
outer `UIWheelHeightThemed` wrapper (it wraps the whole group), so the `picker*` params stay threaded through
`UIWheelHeightPlain` and `nil`-default — leaving the *plain* call undressed, identical to `develop`.

**Landed file-by-file:**

1. `TDEE/ViewsValueEditors/Height/UIWheelHeightPlain.swift` — added `var forceAppearance: Bool = false` and a
   shared `heightWheel(label:selection:rows:)` builder; the four wheels (`UIPickerViewCentimeters` /
   `UIPickerViewInches` / `feetAndInchesWheels`) call it, so each renders the native wheel by default:
   ```swift
   Picker("Cm", selection: $valueCm) {
       ForEach(optionsCm, id: \.self) { value in
           Text("\(value)").tag(value)
       }
   }
   .pickerStyle(.wheel)
   .accessibilityIdentifier("heightCmWheel")
   .pickerPanel(background: pickerBackground, width: pickerPanelWidth)   // no-op when both nil
   ```
   …and `UIThemedWheelPicker` when `forceAppearance` (its forced appearance makes the digits read dark on the
   panel). The `accessibilityIdentifier`, `pickerPanel(background:width:)`, the `UITextPickerLabel` captions +
   `.offset(x:)`, and the `pickerWheelSpacing` `HStack` are unchanged; the cross-fade / sync logic
   (`onAppear`, `onChange`, the converters) stays a single copy shared by both controls.
2. `UIWheelHeightPlain.swift` top comment — now states the plain control is the original native
   `.pickerStyle(.wheel)` and re-asserts the "wheel, not a menu; keep the converters; APPROVAL REQUIRED"
   warning (the old `develop` "DO NOT MODIFY … APPROVAL REQUIRED" had been dropped in this work).
3. `UIWheelHeightThemed.swift` — passes `forceAppearance: palette.pickerColorScheme != nil`; comment corrected
   (the digit colour is forced on the `UIPickerView`, not via a wrapper's `.preferredColorScheme`).
4. **No change** to `SectionEditorHeight` (the `isPickerThemed` switch is correct), to `Theme.swift` /
   `DefaultThemes.swift` (Orange's fields stay), or to `UIThemedWheelPicker` — it's still used by
   `UIWheelAgeThemed` and `UIWheelActivityLevelThemed`, so it must stay.

**Rejected alternative — constrain the `UIPickerView` width on the plain path.** Give each wheel a default
`.frame(width:)` when `pickerPanelWidth` is `nil` (Age's `160`, say). It stops the fill, but the non-Orange
control stays a `UIPickerView` (a non-original look, and the feet-&-inches case needs *two* widths) and it
can't express per-wheel panels. Restoring the native wheel is the faithful "Original control" and is what
Age/Weight do, so it's preferred.

**Outcome / lessons (confirmed in Xcode):**
- The per-wheel panel + forced-appearance `UIThemedWheelPicker` on Orange reads correctly: two separate
  panels, captions outside, digits dark.
- **The digit colour could not be forced on a native wheel.** A first cut kept the native `.pickerStyle(.wheel)`
  on the plain path and tried a wrapper's `.preferredColorScheme(.light)` for the digits — it left Orange's
  digits light on the panel. The colour forces only via the `UIPickerView`'s `overrideUserInterfaceStyle`,
  which is why the *themed* control uses `UIThemedWheelPicker` and the *plain* control stays native.
- **Weight ported (§11.8):** `UIWheelWeightThemed` used the same "native + `.preferredColorScheme`" shape and
  shared the latent light-digit bug on Orange; it now mirrors the height fix (`forceAppearance` + per-wheel
  panel + theme-driven offsets + container breath). Body fat (`UIWheelBodyFatThemed`) is still on the old
  shape — the next port.

**Acceptance.** Build succeeds; on Clouds (a non-Orange theme) the height section matches `develop` (native
wheel, in-bounds captions, not too wide); on Orange the feet & inches wheels show two separate panels with
captions outside and digits dark. This is the pending visual check from §14.

**Respect while changing (§§5–7, 10):** the wheel stays a wheel, never a menu; the cross-fade / sync logic is
load-bearing; "re-derive, never mutate `model.height`" on a UoM switch; `model.height` is always cm;
`UISegmentUomLengthView` stays frozen. Both `SectionEditorHeight` (Classic) and `HeightNewSectionView:87-89`
(New wheel mode) route to these types, so the fix heals both.

## 19. References

- Story 023 (Input Method): `documentation/stories/story-023-input-method/{plan,story}.md`
- Story 018 (Themes): `documentation/stories/story-018-themes/palettes.md`
- `UI_RESTRICTIONS.md` — app-wide UI constraints
- Project memory: *Watch is standalone with local SwiftData* (the watch has no shared height picker).
