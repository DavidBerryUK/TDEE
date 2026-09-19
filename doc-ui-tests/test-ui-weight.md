# UI Test Specification: Weight Section

## Overview

This document specifies the UI test requirements for the **Weight** section of the SimpleTest application.

## Scope

### What this document covers

This specification covers **only** the UI components related to the Weight section:

- The Weight section header (tap-to-expand)
- The Weight unit-of-measure selector (Kg / Pounds / Stones & Pounds)
- The Weight wheel picker control(s)
- Accessibility identifiers for UI testing

### What this document excludes

This specification **excludes** all calculation functionality. While the Weight value is used in calculations (BMR, TDEE, etc.), those calculations are NOT covered in this test specification. This test focuses solely on:

- UI rendering of the Weight section
- User interaction with the unit selector and picker(s)
- Accessibility compliance

## How the Weight Section Works (User Perspective)

### UI Structure

The Weight section is part of the profile input form and appears as follows:

```
┌─────────────────────────────────────────┐
│ Weight               [Tap to expand] ▶  │  ← Section header
├─────────────────────────────────────────┤
│                                         │
│   [ Kg | Pounds | Stones & Pounds ]     │  ← Unit-of-measure selector
│                                         │
│  ┌─────────────────────────────────┐    │
│  │   0                             │    │
│  │   1                             │    │
│  │ ▶ 2   kilograms                 │    │  ← Wheel picker(s)
│  │   3                             │    │
│  │   4                             │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

Weight supports three interchangeable units of measure, each backed by its own wheel picker:

- **Kilograms**: a single wheel, 0-250 kg
- **Pounds**: a single wheel, 0-550 pounds
- **Stones & Pounds**: two wheels side by side, stones (0-40) and pounds (0-13)

Switching the unit selector converts the currently stored weight (always held internally in kilograms) into the newly selected unit and swaps which wheel(s) are visible, with a short cross-fade/scale animation between them.

### User Interactions

1. **View the section**: The Weight section appears in the profile input form with a header "Weight" and a chevron icon indicating it can be expanded

2. **Expand the section**: Tapping anywhere on the section header expands the editor view

3. **Choose a unit**: The user sees a segmented control for Kg / Pounds / Stones & Pounds

4. **Select weight**: Depending on the chosen unit, the user sees one wheel picker (Kg or Pounds) or two wheel pickers side by side (Stones & Pounds)

5. **Make selection**: Scrolling a wheel picker immediately updates the selection

### Behavior Notes

- **Exclusive expansion**: Only one section can be expanded at a time. Expanding the Weight section will collapse any other expanded section (Age, Gender, Height, etc.)
- **Immediate update**: The selection updates immediately when the user scrolls a wheel - no save button required
- **Default value**: When the app first launches, weight is `0`, which is treated as invalid/unset
- **Validation**: While weight is `0`, the section shows the inline error "Please enter a valid Weight" below the header
- **Unit conversion**: Changing the unit selector converts the current weight into the new unit rather than resetting it
- **Summary display**: After collapsing, the section header displays the selected weight in the current unit (e.g., "95 kg", or "1 stone 5 pounds" for Stones & Pounds)

---

## User Acceptance Test

### Test ID: UAT-WEIGHT-001

**Title**: User can view and select weight from the wheel picker

**Preconditions**:
- The app is installed and can be launched
- The user has access to the profile input screen

**Test Steps**:

1. Launch the app
2. Observe the Weight section in the profile input form
3. Tap on the Weight section header to expand it
4. Verify the unit-of-measure selector is visible, defaulted to "Kg"
5. Verify the wheel picker is visible
6. Verify the section shows a validation error, since weight starts at 0
7. Scroll and select a value in the wheel picker
8. Verify the validation error clears once a non-zero weight is selected

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 2 | Weight section is visible with header "Weight" and expandable chevron |
| 3 | Section expands to show the unit selector and the wheel picker editor |
| 4 | Segmented control shows "Kg" selected by default |
| 5 | Kilograms wheel picker (0-250) is visible |
| 6 | "Please enter a valid Weight" is displayed |
| 7 | Selection changes to the picked value in the editor |
| 8 | The validation message is no longer shown |

**Accessibility Requirements**:

- Section header must have accessibility identifier: `sectionWeight`
- Editor container must have accessibility identifier: `editorWeight`
- Unit selector must have accessibility label: `Weight unit selector`
- Unit selector must have accessibility value: `Current: <unit display name>`
- Kilograms wheel picker must have accessibility label: `Weight picker`
- Kilograms wheel picker must have accessibility identifier: `weightPicker`
- Kilograms wheel picker must have accessibility value: `Current weight: X kg` (where X is the selected weight in kg)
- Summary major value must have accessibility label: `Weight major value`
- Summary major unit must have accessibility label: `Weight major units`
- Summary minor value must have accessibility label: `Weight minor value`
- Summary minor unit must have accessibility label: `Weight minor units`

---

## Current Implementation Status

### Existing Test

A UI test exists at: `SimpleTestUITests/SimpleTestUITests_Weight.swift`

**Test name**: `testWeightPickerExists()`

**What it tests**:
- The Weight section can be tapped/expanded
- A wheel picker exists in the accessibility hierarchy

---

## Missing Test Scenarios

The following behaviors are **not currently tested**:

### UAT-WEIGHT-002: Weight summary updates when selection changes

**What it tests**: When the user selects a different weight in the wheel picker, the summary value displayed in the section header updates correctly after collapsing the section.

**Test Steps**:

1. Launch the app
2. Tap the Weight section header to expand it
3. Scroll and select a weight value in the kilograms wheel picker
4. Tap the Weight section header again to collapse it
5. Verify the summary now displays the selected weight

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 3 | Selection changes to the picked value in the editor |
| 4 | Section collapses |
| 5 | Summary displays the selected weight and unit (e.g., "95 kg") |

### UAT-WEIGHT-003: Switching unit of measure converts the displayed weight

**What it tests**: Changing the unit selector (Kg / Pounds / Stones & Pounds) swaps the visible wheel picker(s) and converts the currently stored weight into the new unit, rather than resetting it - and, critically, that the **collapsed section header summary** reflects the converted value and unit each time, not just the in-editor wheel.

**Test Steps**:

1. Launch the app
2. Tap the Weight section header to expand it
3. Select a weight value in kilograms
4. Tap "Pounds" in the unit selector
5. Verify the pounds wheel picker is now visible, showing the converted value
6. Collapse the section and verify the summary displays the converted value in pounds (not kg)
7. Expand the section again and tap "Stones & Pounds" in the unit selector
8. Verify two wheel pickers (stones, pounds) are now visible, showing the converted value
9. Collapse the section and verify the summary displays the converted value as stones and pounds

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 4 | Unit selector shows "Pounds" selected |
| 5 | Pounds wheel picker is visible with a value consistent with the previously selected kilograms |
| 6 | Summary shows the same weight converted into pounds, with the "pounds" unit label (e.g. "209 pounds") |
| 7 | Unit selector shows "Stones & Pounds" selected |
| 8 | Stones and pounds wheel pickers are visible with values consistent with the previously selected kilograms |
| 9 | Summary shows the same weight converted into stones and pounds, with both unit labels (e.g. "14 stones 13 pounds") |

**Note**: This is the scenario most worth testing end-to-end, since it exercises the full round trip: wheel selection → `model.weight` (always stored in kg) → unit conversion on `weightUom` change → `UISectionSummaryValueWeight`'s major/minor value and unit labels. A bug in `WeightConvertor` or in how the summary picks `labelMajorUnit`/`labelMinorUnit` per `OptionWeight` would only be caught by checking the header after collapsing, not by checking the wheel alone.

### UAT-WEIGHT-004: Weight validation error clears once a value is selected

**What it tests**: The "Please enter a valid Weight" validation message shown while weight is `0` disappears once the user selects a non-zero weight.

**Test Steps**:

1. Launch the app
2. Tap the Weight section header to expand it
3. Verify the validation message is visible (weight defaults to 0)
4. Scroll and select any non-zero value in the wheel picker
5. Verify the validation message is no longer visible

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 3 | "Please enter a valid Weight" is displayed |
| 4 | Selection changes to the picked value in the editor |
| 5 | The validation message is no longer displayed |

**Note**: This mirrors the validation behavior implemented in `SectionWeight.swift`, which derives `validationText` from whether `model.weight` is `0` or `NaN`.

---

## Key Differences from Height Section

While the Weight section is very similar to Height, there are some important differences:

| Aspect | Height | Weight |
|--------|--------|--------|
| Unit options | Centimeters, Inches, Feet & Inches | Kilograms, Pounds, Stones & Pounds |
| Value range (primary) | 0-272 cm | 0-250 kg |
| Value range (inches/pounds) | 0-107 inches | 0-550 pounds |
| Value range (stones/feet) | 0-8 feet, 0-11 inches | 0-40 stones, 0-13 pounds |
| Internal storage | Centimeters | Kilograms |
| Conversion factor | 2.54 cm per inch | 0.45359237 kg per pound |
| Summary minor unit (multi) | "inches" | "pounds" |
| Accessibility identifier | `heightCmPicker` | `weightPicker` |

---

## Implementation Notes

The Weight section uses the same pattern as Height for unit switching:

1. **ZStack with opacity transitions**: All three wheel variants are mounted simultaneously, with opacity/scale/offset animations controlled by `unitOfMeasure`
2. **State synchronization**: `syncStateFromPreviousUnit()` converts between units when switching
3. **Conversion service**: `WeightConvertor` handles kg↔pounds↔stones conversions

See [ios-ui-testing-findings.md](./ios-ui-testing-findings.md) for the general lessons about SwiftUI wheel pickers - most of those findings (especially #3, #4, #5, #8) apply equally to the Weight section.
