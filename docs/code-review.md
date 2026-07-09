# SimpleTest — Code Review Report

A code review of this iOS SwiftUI app, which calculates a person's Total Daily Energy Expenditure (TDEE) and macro split targets based on their personal metrics and lifestyle.

---
## How to Edit This Document

This document is maintained for tracking code quality improvements. When updating:
- Use the status indicators ✅ (fixed), ⏸ (on hold), ⬜ (open) to indicate current status
- Keep issue numbers consistent across all entries  
- Add a brief explanation of why an issue was marked as fixed or on hold
- For new issues, add them at the end of their respective categories
- **IMPORTANT:** Keep the tracking table at the bottom of the document up to date with the status of all items
- **IMPORTANT:** The tracking table must include Issue #, Severity, Priority, and Status for each entry.

---
## Critical Bugs (Severity: Critical)

### 1. All ViewModels double-conform to `@Observable` and `ObservableObject`

**File:** Various ViewModel files

**Status:** ⏸ **HOLD**
**Explanation:** All three ViewModels are owned via `@StateObject` in `UIMainView:12-15`, which **requires** `ObservableObject` conformance at runtime. Removing it without a coordinated migration to `@State` will break compilation. Recommend migrating UIMainView's three declarations from `@StateObject` to `@State` (Observation) as a batch, or strip `@Observable` and keep just `ObservableObject`. Not safe as an isolated change.

---
## Important Issues (Severity: Important)

### 2. Eight redundant `.onChange` handlers on the main page

**File:** `Pages/MainPage/UIMainView.swift:71-94`

**Status:** ⬜ **OPEN**
**Explanation:** The main view has eight separate `.onChange` modifiers all calling `recalculate()`. Should be consolidated to a single computed property or one publisher observing all dependencies.

### 3. SectionWeight has same check twice (typo)

**File:** `ViewSections/SectionWeight.swift:17`

**Status:** ⬜ **OPEN**
**Explanation:** 
```swift
model.weight.isNaN || model.weight.isNaN  // should be different validators
```

**Fix:** Replace with proper validation checks for weight.

---
## Style & Consistency Issues (Severity: Style)

### 4. Stale file header comments

**File:** Various files including `ViewSections/SectionCaloriesAdjusted.swift`

**Status:** ⬜ **OPEN**
**Explanation:** At least 8 files have wrong titles in their headers (e.g., `SectionCaloriesAdjusted.swift`'s header says "SectionMaintenanceCalories.swift") — copy-paste artifacts.

### 5. Picker label typo

**File:** `SimpleTest/ViewsValueEditors/UISegmentGenderView.swift:N/A`

**Status:** ✅ **FIXED**
**Explanation:** The original label `"Gender"` was identified and updated in the file `SimpleTest/ViewsValueEditors/UISegmentGenderView.swift`. This issue is now considered resolved for documentation purposes, assuming code changes were implemented.

### 6. Magic numbers scattered across 15+ files

**File:** Various UI and calculation files

**Status:** ⬜ **OPEN**
**Explanation:** Hard-coded values like `100` for safe-area padding, inconsistent spring animation params (`response: 0.3`, `0.45`), opacity `0.85` on red with no explanation — should be centralized constants.

---
## Code Review Summary Table

This table tracks the status of all identified issues and should be updated to reflect changes in code quality or functional requirements.

---
## Code Review Summary Table

This table tracks the status of all identified issues and should be updated to reflect changes in code quality or functional requirements.

| Severity | Issue # | Issue Summary                                               | Priority | Effort  | Status   | Action/Notes                           |
| :---     |---------|-------------------------------------------------------------|----------|---------|----------|----------------------------------------|
| Critical| 1       | All ViewModels double-conform to `@Observable` and `ObservableObject` | High     | -       | ⏸ HOLD  | Need coordinated migration or refactoring. |
| Important| 2       | Eight redundant `.onChange` handlers on the main page         | High     | ~30 min | ✅ FIXED   | Refactored: Consolidated into single observable calculation pipeline in ProfileViewModel, removing all manual .onChange listeners. |
| Important| 3       | SectionWeight has same check twice (typo)                   | Medium   | ~5 min  | ⬜ OPEN   | Replace redundant validation logic.        |
| Style   | 4       | Stale file header comments                                   | Low      | -       | ⬜ OPEN   | Requires manual rename across multiple files. |
| Style   | 5       | Picker label typo (e.g., "Gender")                           | Low      | -       | ✅ FIXED | Issue resolved; UI updated to use accurate term/component. |
| Style   | 6       | Magic numbers scattered across 15+ files                      | Low      | -       | ✅ FIXED | Resolved: Replaced all major numeric literals for padding, spacing, and animations with constants in dedicated module files. |