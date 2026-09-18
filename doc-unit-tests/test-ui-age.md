# UI Test Specification: Age Section

## Overview

This document specifies the UI test requirements for the **Age** section of the SimpleTest application.

## Scope

### What this document covers

This specification covers **only** the UI components related to the Age section:

- The Age section header (tap-to-expand)
- The Age wheel picker control
- Accessibility identifiers for UI testing

### What this document excludes

This specification **excludes** all calculation functionality. While the Age value is used in calculations (BMR, TDEE, etc.), those calculations are NOT covered in this test specification. This test focuses solely on:

- UI rendering of the Age section
- User interaction with the Age picker
- Accessibility compliance

## How the Age Section Works (User Perspective)

### UI Structure

The Age section is part of the profile input form and appears as follows:

```
┌─────────────────────────────────────────┐
│ Age                 [Tap to expand] ▶   │  ← Section header
├─────────────────────────────────────────┤
│                                         │
│  ▼ Age picker                           │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  16  17  18  19  20  ...      │    │
│  │  30  31  32  33  34  ...      │    │  ← Wheel picker
│  │  40  41  42  43  44  ...      │    │
│  │  50  51  52  53  54  ...      │    │
│  │  60  61  62  63  64  ...      │    │
│  │  70  71  72  73  74  ...      │    │
│  │  80  81  82  83  84  ...      │    │
│  │  90  91  92  93  94  ...      │    │
│  │  95  96  97  98  99           │    │
│  └─────────────────────────────────┘    │
│  age in years                           │
│                                         │
└─────────────────────────────────────────┘
```

### User Interactions

1. **View the section**: The Age section appears in the profile input form with a header "Age" and a chevron icon indicating it can be expanded

2. **Expand the section**: Tapping anywhere on the section header expands the editor view

3. **Select age**: The user sees a wheel picker with options from 16 to 99 years

4. **Make selection**: Tapping a number in the wheel picker immediately updates the selection

### Behavior Notes

- **Exclusive expansion**: Only one section can be expanded at a time. Expanding the Age section will collapse any other expanded section (Gender, Height, Weight, etc.)
- **Immediate update**: The selection updates immediately when the user taps a number - no save button required
- **Default value**: When the app first launches, "21" is the default age
- **Summary display**: After collapsing, the section header displays the selected age (e.g., "34 years")

---

## User Acceptance Test

### Test ID: UAT-AGE-001

**Title**: User can view and select age from the wheel picker

**Preconditions**:
- The app is installed and can be launched
- The user has access to the profile input screen

**Test Steps**:

1. Launch the app
2. Observe the Age section in the profile input form
3. Tap on the Age section header to expand it
4. Verify the wheel picker is visible
5. Verify the picker shows options from 16 to 99
6. Verify "21" is the selected age (default)
7. Scroll and select "34" in the wheel picker
8. Verify "34" is now the selected age
9. Scroll and select "65" in the wheel picker
10. Verify "65" is now the selected age

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 2 | Age section is visible with header "Age" and expandable chevron |
| 3 | Section expands to show the wheel picker editor |
| 4 | Wheel picker with age options (16-99) is visible |
| 5 | Options 16-99 are scrollable in the picker |
| 6 | "21" is selected by default |
| 7 | Selection changes to "34" in the editor |
| 8 | "34" remains selected after selection |
| 9 | Selection changes to "65" in the editor |
| 10 | "65" remains selected after selection |

**Accessibility Requirements**:

- Section header must have accessibility identifier: `sectionAge`
- Wheel picker must have accessibility label: `Age picker`
- Wheel picker must have accessibility identifier: `agePicker`
- Wheel picker must have accessibility value: `Current age: X years` (where X is the selected age)

---

## Current Implementation Status

### Existing Test

A UI test exists at: `SimpleTestUITests/SimpleTestUITests_Age.swift`

**Test name**: `testAgePickerExists()`

**What it tests**:
- The Age section can be tapped/expanded
- The wheel picker exists in the accessibility hierarchy

**Test code reference**: The test uses `utils.findPicker(in: app)` to locate the wheel picker element.

---

## Missing Test Scenarios

### UAT-AGE-002: Age summary updates when selection changes

**What it tests**: When the user selects a different age in the wheel picker, the summary value displayed in the section header updates correctly after collapsing the section.

**Test Steps**:

1. Launch the app
2. Tap the Age section header to expand it
3. Verify "21" is displayed in the summary (default)
4. Scroll and select "34" in the wheel picker
5. Tap the Age section header again to collapse it
6. Verify the summary now displays "34"
7. Tap the Age section header to expand it again
8. Verify "34" is still selected in the wheel picker

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 3 | Summary displays "21 years" |
| 4 | Selection changes to "34" in the editor |
| 5 | Section collapses |
| 6 | Summary now displays "34 years" |
| 7 | Section expands |
| 8 | "34" remains selected in the wheel picker |

**Note**: This scenario verifies that the `@Bindable` properties properly propagate changes from the editor view back to the profile model, and that the summary view correctly reflects those changes.

### UAT-AGE-003: Age range validation

**What it tests**: The wheel picker provides the complete range of valid ages (16-99 years).

**Test Steps**:

1. Launch the app
2. Tap the Age section header to expand it
3. Verify the minimum age option is "16"
4. Verify the maximum age option is "99"
5. Verify all ages in the range 16-99 are available

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 3 | First visible age option is "16" |
| 4 | Last visible age option is "99" |
| 5 | Range includes all integers from 16 to 99 inclusive |

**Note**: This ensures the age picker is configured with the correct minimum (16) and maximum (99) age constraints.
