# UI Test Specification: Gender Section

## Overview

This document specifies the UI test requirements for the **Gender** section of the SimpleTest application.

## Scope

### What this document covers

This specification covers **only** the UI components related to the Gender section:

- The Gender section header (tap-to-expand)
- The Gender segmented control picker (Male/Female)
- Accessibility identifiers for UI testing

### What this document excludes

This specification **excludes** all calculation functionality. While the Gender value is used in calculations (BMR, TDEE, etc.), those calculations are NOT covered in this test specification. This test focuses solely on:

- UI rendering of the Gender section
- User interaction with the Gender selector
- Accessibility compliance

## How the Gender Section Works (User Perspective)

### UI Structure

The Gender section is part of the profile input form and appears as follows:

```
┌─────────────────────────────────────────┐
│ Gender              [Tap to expand] ▶   │  ← Section header
├─────────────────────────────────────────┤
│                                         │
│  ▼ Gender selector                      │
│                                         │
│  (Male)  [ ]  (Female)                  │  ← Segmented control
│                                         │
└─────────────────────────────────────────┘
```

### User Interactions

1. **View the section**: The Gender section appears in the profile input form with a header "Gender" and a chevron icon indicating it can be expanded

2. **Expand the section**: Tapping anywhere on the section header expands the editor view

3. **Select gender**: The user sees a segmented control with two options:
   - **Male** (default selection)
   - **Female**

4. **Make selection**: Tapping either "Male" or "Female" immediately updates the selection

### Behavior Notes

- **Exclusive expansion**: Only one section can be expanded at a time. Expanding the Gender section will collapse any other expanded section (Age, Height, Weight, etc.)
- **Immediate update**: The selection updates immediately when the user taps a button - no save button required
- **Default value**: When the app first launches, "Male" is the selected gender

---

## User Acceptance Test

### Test ID: UAT-GENDER-001

**Title**: User can view and select gender from the segmented control

**Preconditions**:
- The app is installed and can be launched
- The user has access to the profile input screen

**Test Steps**:

1. Launch the app
2. Observe the Gender section in the profile input form
3. Tap on the Gender section header to expand it
4. Verify the segmented control is visible
5. Verify "Male" is the selected option (default)
6. Tap "Female" on the segmented control
7. Verify "Female" is now the selected option
8. Tap "Male" on the segmented control
9. Verify "Male" is now the selected option

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 2 | Gender section is visible with header "Gender" and expandable chevron |
| 3 | Section expands to show the segmented control editor |
| 4 | Segmented control with "Male" and "Female" buttons is visible |
| 5 | "Male" button is selected (highlighted) by default |
| 6 | "Female" button becomes selected when tapped |
| 7 | "Male" button becomes selected when tapped |
| 8 | Selection persists after tapping |

**Accessibility Requirements**:

- Section header must have accessibility identifier: `sectionGender`
- Segmented control must have accessibility label: `Gender selector`
- Segmented control must have accessibility identifier: `Gender`
- Each button must have accessible labels: "Male" and "Female"

---

## Current Implementation Status

### Existing Test

A UI test exists at: `SimpleTestUITests/SimpleTestUITests_Gender.swift`

**Test name**: `testGenderSelectorExists()` in `SimpleTestUITests/SimpleTestUITests_Gender.swift`

**What it tests**:
- The Gender section can be tapped/expanded
- The segmented control exists in the accessibility hierarchy
- Both "Male" and "Female" buttons are present

---

## Missing Test Scenario

The following behavior is **NOT currently tested**:

### UAT-GENDER-002: Gender summary updates when selection changes

**What it tests**: When the user selects a different gender option, the summary value displayed in the section header updates correctly after collapsing the section.

**Test Steps**:

1. Launch the app
2. Tap the Gender section header to expand it
3. Verify "Male" is displayed in the summary (default)
4. Tap "Female" on the segmented control
5. Tap the Gender section header again to collapse it
6. Verify the summary now displays "Female"
7. Tap the Gender section header to expand it again
8. Verify "Female" is still selected in the segmented control

**Expected Results**:

| Step | Expected Outcome |
|------|------------------|
| 3 | Summary displays "Male" |
| 4 | Selection changes to "Female" in the editor |
| 5 | Section collapses |
| 6 | Summary now displays "Female" |
| 7 | Section expands |
| 8 | "Female" button remains selected |

**Note**: This scenario verifies that the `@Bindable` properties properly propagate changes from the editor view back to the profile model, and that the summary view correctly reflects those changes.
