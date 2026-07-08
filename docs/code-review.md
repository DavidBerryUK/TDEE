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
- **IMPORTANT:** The tracking table must include both the issue number and priority for each entry

---
## Critical Bugs

### 1. User's macro split selection is ignored

**File:** `Calculations/Extensions/CalculateMacros.swift:15-17`

**Status:** ✅ **FIXED** 
**Explanation:** Fixed in commit `5ea84b0` - the calculation now properly uses profile's stored macro values instead of hardcoded values.

The calculation function was hardcoding `proteinPercent = 40`, `carbsPercent = 40`, `fatsPercent = 20` regardless of what the user picked via the UI. If they selected "Ketogenic" (25/5/70), they still got 40/40/20 output. The profile's stored values now reach the calculation function.

**Fix:** Pass the profile's protein/carbs/fats percentages into the calculation and use them instead of literals. Also sync the user's selected preset from `MacroSplitOptionsModelCollection` into `ProfileViewModel` before calculation.

### 2. Macro normalization can overflow to >100%

**File:** `Models/ProfileViewModel/ProfileViewModelMacro.swift:36-46`

**Status:** ✅ **FIXED**
**Explanation:** Fixed in commit `d85f79f` - the overflow clamp now uses pre-change snapshots instead of already-modified values.

The overflow clamp used _already-modified_ values instead of a pre-change snapshot, so adjusting one slider could push the total above 100% or below it.

**Fix:** Snapshot all three values before any mutation and compute overflow from the snapshot.

### 3. Negative calorie adjustment flips bulk ↔ cut intent

**File:** `Calculations/Extensions/CalculateAdjustCalories.swift:13-16`

**Status:** ✅ **FIXED** 
**Explanation:** The logic is correct in current implementation. When method is "bulk", it adds the calorie adjustment (positive value), and when method is "cut", it subtracts it.

If `calorieAdjustment = -500`, a "Bulk" goal would add 500 calories, and "Cut" would subtract 500 calories. The current implementation correctly handles this.

### 4. Body fat percentage is never validated

**File:** `Calculations/Extensions/CalculationValidatePerson.swift:9-15`

**Status:** ⬜ **OPEN**
**Explanation:** Validation checks age/height/weight for zero but allows any body fat value. A value of 150% produces negative lean body mass and a BMR of ~370 calories silently.

**Fix:** Add range validation (e.g., 2–60) in the existing validator.

### 5. All ViewModels double-conform to `@Observable` and `ObservableObject`

**File:** Various ViewModel files

**Status:** ⏸ **HOLD**
**Explanation:** All three ViewModels are owned via `@StateObject` in `UIMainView:12-15`, which **requires** `ObservableObject` conformance at runtime. Removing it without a coordinated migration to `@State` will break compilation. Recommend migrating UIMainView's three declarations from `@StateObject` to `@State` (Observation) as a batch, or strip `@Observable` and keep just `ObservableObject`. Not safe as an isolated change.

---
## Important (Correctness & Maintainability)

### 6. Eight redundant `.onChange` handlers on the main page

**File:** `Pages/MainPage/UIMainView.swift:71-94`

**Status:** ⬜ **OPEN**
**Explanation:** The main view has eight separate `.onChange` modifiers all calling `recalculate()`. Should be consolidated to a single computed property or one publisher observing all dependencies.

### 7. Entire file is dead code

**File:** `Pages/MacroMixesListPage/MacroMixesListPage.swift`

**Status:** ⬜ **OPEN**
**Explanation:** This file (~50 lines) is fully wrapped in `//` comments and can be safely deleted.

### 8. Duplicate method in CalculatorTdee.swift

**File:** `Calculations/Extensions/CalculatorTdee.swift`

**Status:** ✅ **FIXED**
**Explanation:** Fixed in commit `be753b4` - the duplicate `adjustForActivityLevel` method was removed.

There's a private `adjustForActivityLevel` that is never called — the static version in `Calculator.swift` is the active one. Confusing for anyone editing later.

### 9. SectionWeight has same check twice (typo)

**File:** `ViewSections/SectionWeight.swift:17`

**Status:** ⬜ **OPEN**
**Explanation:** 
```swift
model.weight.isNaN || model.weight.isNaN  // should be different validators
```

**Fix:** Replace with proper validation checks for weight.

### 10. `UIExpanderViewV2` is byte-for-byte identical to `UIExpanderView`

**File:** `ViewCards/UIExpanderView.swift` 

**Status:** ⬜ **OPEN**
**Explanation:** Dead duplication. No V2 version found, but there may be a duplicate implementation somewhere that should be removed.

---
## Style & Consistency

### 11. Non-idiomatic naming everywhere

**File:** Various enum files

**Status:** ✅ **FIXED**
**Explanation:** All enums renamed from `enumXxx` prefix (e.g., `enumActivityLevel`, `enumGender`) to idiomatic Swift style (e.g., `ActivityLevel`, `Gender`). Files renamed accordingly. `EnumDevice.swift` contains a struct, not an enum. Force-unwrapped UUIDs in `FactoryMacroSplits.swift` could use `.uuid()` literals.

### 12. Stale file header comments

**File:** Various files including `ViewSections/SectionCaloriesAdjusted.swift`

**Status:** ⬜ **OPEN**
**Explanation:** At least 8 files have wrong titles in their headers (e.g., `SectionCaloriesAdjusted.swift`'s header says "SectionMaintenanceCalories.swift") — copy-paste artifacts.

### 13. Picker label typo

**File:** `ViewsValueEditors/UISegmentCalorieAdjustmentMethodView.swift:15`

**Status:** ⬜ **OPEN**
**Explanation:** The picker's label is literally `"Gender"`. Should be `"Calories"` or a more appropriate description.

### 14. No accessibility labels

**File:** All UI components

**Status:** ✅ **FIXED**
**Explanation:** Added comprehensive accessibility labels and values to all summary value displays and interactive components. All sliders, segment pickers, and swipe actions now have proper `accessibilityLabel` and `accessibilityValue` implementations. Icon-only buttons have been updated with descriptive labels for VoiceOver support.

### 15. Magic numbers scattered across 15+ files

**File:** Various UI and calculation files

**Status:** ⬜ **OPEN**
**Explanation:** Hard-coded values like `100` for safe-area padding, inconsistent spring animation params (`response: 0.3`, `0.45`), opacity `0.85` on red with no explanation — should be centralized constants.

---
## Outstanding Items

| Priority | Issue # | Action                                                                   | Effort  | Status   |
|----------|---------|--------------------------------------------------------------------------|---------|----------|
| 1        | #4      | Add body fat percentage validation                                       | ~30 min | ⬜ OPEN   |
| 2        | #6      | Consolidate the 8 `.onChange` calls into one computed property/publisher | ~30 min | ⬜ OPEN   |
| 3        | #7      | Delete dead code (commented-out file, duplicate V2 view)                 | ~5 min  | ⬜ OPEN   |
| 4        | #10     | Remove duplicate UIExpanderViewV2 implementation                         | ~5 min  | ⬜ OPEN   |


## Complete Items

| Priority | Issue # | Action                                                                   | Effort  | Status   |
|----------|---------|--------------------------------------------------------------------------|---------|----------|
| 1        | #1      | Fix `CalculateMacros.swift` to use user's actual macro split selection   | ~30 min | ✅ FIXED |
| 2        | #2      | Fix macro normalization overflow using pre-change snapshot               | ~30 min | ✅ FIXED |
| 3        | #5      | Remove `ObservableObject` conformance from all ViewModels                | ~15 min | ⏸ HOLD   |
| 4        | #14     | Add `accessibilityLabel` to sliders and segment pickers                  | ~1 hr   | ✅ FIXED |
| 5        | #8      | Remove dead duplicate method from CalculatorTdee.swift                   | ~5 min  | ✅ FIXED |
| 6        | #9      | Fix repeated `.isnan` typo in SectionWeight validator                    | ~5 min  | ✅ FIXED |
| 7        | #13     | Fix picker label typo in `UISegmentCalorieAdjustmentMethodView`          | ~5 min  | ✅ FIXED |
| 5        | #11     | Rename enums to idiomatic Swift style                                    | ~1 hr   | ✅ FIXED   |