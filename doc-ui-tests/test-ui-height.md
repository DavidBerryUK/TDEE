# UI Test Specification: Height Section

## Overview

This document specifies the UI test requirements for the **Height** section of the SimpleTest application.

## Scope

### What this document covers

This specification covers **only** the UI components related to the Height section:

- The Height section header (tap-to-expand)
- The Height unit-of-measure selector (Cm / Inches / Feet & Inches)
- The Height wheel picker control(s)
- Accessibility identifiers for UI testing

### What this document excludes

This specification **excludes** all calculation functionality. While the Height value is used in calculations (BMR, TDEE, etc.), those calculations are NOT covered in this test specification. This test focuses solely on:

- UI rendering of the Height section
- User interaction with the unit selector and picker(s)
- Accessibility compliance

## How the Height Section Works (User Perspective)

### UI Structure

The Height section is part of the profile input form and appears as follows:

```
┌─────────────────────────────────────────┐
│ Height               [Tap to expand] ▶  │  ← Section header
├─────────────────────────────────────────┤
│                                         │
│   [ Cm | Inches | Feet & Inches ]       │  ← Unit-of-measure selector
│                                         │
│  ┌─────────────────────────────────┐    │
│  │   118                           │    │
│  │   119                           │    │
│  │ ▶ 120  centimeters              │    │  ← Wheel picker(s)
│  │   121                           │    │
│  │   122                           │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

Unlike Age and Gender, Height supports three interchangeable units of measure, each backed by its own wheel picker:

- **Centimeters**: a single wheel, 0-272 cm
- **Inches**: a single wheel, 0-107 inches
- **Feet & Inches**: two wheels side by side, feet (0-8) and inches (0-11)

Switching the unit selector converts the currently stored height (always held internally in centimeters) into the newly selected unit and swaps which wheel(s) are visible, with a short cross-fade/scale animation between them.

### User Interactions

1. **View the section**: The Height section appears in the profile input form with a header "Height" and a chevron icon indicating it can be expanded

2. **Expand the section**: Tapping anywhere on the section header expands the editor view

3. **Choose a unit**: The user sees a segmented control for Cm / Inches / Feet & Inches

4. **Select height**: Depending on the chosen unit, the user sees one wheel picker (Cm or Inches) or two wheel pickers side by side (Feet & Inches)

5. **Make selection**: Scrolling a wheel picker immediately updates the selection

### Behavior Notes

- **Exclusive expansion**: Only one section can be expanded at a time. Expanding the Height section will collapse any other expanded section (Age, Gender, Weight, etc.)
- **Immediate update**: The selection updates immediately when the user scrolls a wheel - no save button required
- **Default value**: When the app first launches, height is `0`, which is treated as invalid/unset
- **Validation**: While height is `0`, the section shows the inline error "Please enter a valid Height" below the header
- **Unit conversion**: Changing the unit selector converts the current height into the new unit rather than resetting it
- **Summary display**: After collapsing, the section header displays the selected height in the current unit (e.g., "120 cm", or "5 feet 10 inches" for Feet & Inches)

---

## User Acceptance Test

### Test ID: UAT-HEIGHT-001

**Title**: User can view and select height from the wheel picker

**Preconditions**:
- The app is installed and can be launched
- The user has access to the profile input screen

**Test Steps**:

1. Launch the app
2. Observe the Height section in the profile input form
3. Tap on the Height section header to expand it
4. Verify the unit-of-measure selector is visible, defaulted to "Cm"
5. Verify the wheel picker is visible
6. Verify the section shows a validation error, since height starts at 0
7. Scroll and select a value in the wheel picker
8. Verify the validation error clears once a non-zero height is selected

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 2 | Height section is visible with header "Height" and expandable chevron |
| 3 | Section expands to show the unit selector and the wheel picker editor |
| 4 | Segmented control shows "Cm" selected by default |
| 5 | Centimeters wheel picker (0-272) is visible |
| 6 | "Please enter a valid Height" is displayed |
| 7 | Selection changes to the picked value in the editor |
| 8 | The validation message is no longer shown |

**Accessibility Requirements**:

- Section header must have accessibility identifier: `sectionHeight`
- Editor container must have accessibility identifier: `editorHeight`
- Unit selector must have accessibility label: `Length unit selector`
- Unit selector must have accessibility value: `Current: <unit display name>`
- Centimeters wheel picker must have accessibility label: `Height picker`
- Centimeters wheel picker must have accessibility identifier: `heightCmPicker`
- Centimeters wheel picker must have accessibility value: `Current height: X cm` (where X is the selected height in cm)
- Summary major value must have accessibility label: `Height major value`
- Summary major unit must have accessibility label: `Height major units`
- Summary minor value must have accessibility label: `Height minor value`
- Summary minor unit must have accessibility label: `Height minor units`

---

## Current Implementation Status

### Existing Test

A UI test exists at: `SimpleTestUITests/SimpleTestUITests_Height.swift`

**Test names**:
- `testHeightPickerExists()` - verifies the height picker exists after expanding the section

**What it tests**:
- The Height section can be tapped/expanded
- A wheel picker exists in the accessibility hierarchy

---

## Missing Test Scenarios

The following behaviors are **not currently tested**:

### UAT-HEIGHT-002: Height summary updates when selection changes

**What it tests**: When the user selects a different height in the wheel picker, the summary value displayed in the section header updates correctly after collapsing the section.

**Test Steps**:

1. Launch the app
2. Tap the Height section header to expand it
3. Scroll and select a height value in the centimeters wheel picker
4. Tap the Height section header again to collapse it
5. Verify the summary now displays the selected height

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 3 | Selection changes to the picked value in the editor |
| 4 | Section collapses |
| 5 | Summary displays the selected height and unit (e.g., "120 cm") |

### UAT-HEIGHT-003: Switching unit of measure converts the displayed height

**What it tests**: Changing the unit selector (Cm / Inches / Feet & Inches) swaps the visible wheel picker(s) and converts the currently stored height into the new unit, rather than resetting it - and, critically, that the **collapsed section header summary** reflects the converted value and unit each time, not just the in-editor wheel.

**Test Steps**:

1. Launch the app
2. Tap the Height section header to expand it
3. Select a height value in centimeters
4. Tap "Inches" in the unit selector
5. Verify the inches wheel picker is now visible, showing the converted value
6. Collapse the section and verify the summary displays the converted value in inches (not cm)
7. Expand the section again and tap "Feet & Inches" in the unit selector
8. Verify two wheel pickers (feet, inches) are now visible, showing the converted value
9. Collapse the section and verify the summary displays the converted value as feet and inches

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 4 | Unit selector shows "Inches" selected |
| 5 | Inches wheel picker is visible with a value consistent with the previously selected centimeters |
| 6 | Summary shows the same height converted into inches, with the "inches" unit label (e.g. "47 inches") |
| 7 | Unit selector shows "Feet & Inches" selected |
| 8 | Feet and inches wheel pickers are visible with values consistent with the previously selected centimeters |
| 9 | Summary shows the same height converted into feet and inches, with both unit labels (e.g. "3 feet 11 inches") |

**Note**: This is the scenario most worth testing end-to-end, since it exercises the full round trip: wheel selection → `model.height` (always stored in cm) → unit conversion on `heightUom` change → `UISectionSummaryValueHeight`'s major/minor value and unit labels. A bug in `LengthConverter` or in how the summary picks `labelMajorUnit`/`labelMinorUnit` per `OptionLength` would only be caught by checking the header after collapsing, not by checking the wheel alone.

### UAT-HEIGHT-004: Height validation error clears once a value is selected

**What it tests**: The "Please enter a valid Height" validation message shown while height is `0` disappears once the user selects a non-zero height.

**Test Steps**:

1. Launch the app
2. Tap the Height section header to expand it
3. Verify the validation message is visible (height defaults to 0)
4. Scroll and select any non-zero value in the wheel picker
5. Verify the validation message is no longer visible

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 3 | "Please enter a valid Height" is displayed |
| 4 | Selection changes to the picked value in the editor |
| 5 | The validation message is no longer displayed |

**Note**: This mirrors the validation behavior implemented in `SectionHeight.swift`, which derives `validationText` from whether `model.height` is `0` or `NaN`.
