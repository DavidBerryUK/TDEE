# SimpleTest — Code Review Report

A code review of this iOS SwiftUI app, which calculates a person's Total Daily Energy Expenditure (TDEE) and macro split targets based on their personal metrics and lifestyle.

---

## Critical Bugs

### 1. User's macro split selection is ignored

**File:** `Calculations/Extensions/CalculateMacros.swift:15-17`

The calculation function hardcodes `proteinPercent = 40`, `carbsPercent = 40`, `fatsPercent = 20` regardless of what the user picked via the UI. If they select "Ketogenic" (25/5/70), they still get 40/40/20 output. The profile's stored values never reach the calculation function.

**Fix:** Pass the profile's protein/carbs/fats percentages into the calculation and use them instead of literals. Also sync the user's selected preset from `MacroSplitOptionsModelCollection` into `ProfileViewModel` before calculation.

| Priority | Action                                                                 | Effort  | Status    |
| -------- | ---------------------------------------------------------------------- | ------- | --------- |
| 1        | Fix `CalculateMacros.swift` to use user's actual macro split selection | ~30 min | **FIXED** |

### 2. Macro normalization can overflow to >100%

**File:** `Models/ProfileViewModel/ProfileViewModelMacro.swift:36-46`

The overflow clamp uses _already-modified_ values instead of a pre-change snapshot, so adjusting one slider can push the total above 100%.

**Fix:** Snapshot all three values before any mutation and compute overflow from the snapshot.

| Priority | Action                                                     | Effort  | Status |
| -------- | ---------------------------------------------------------- | ------- | ------ |
| 4        | Fix macro normalization overflow using pre-change snapshot | ~30 min | Open   |

### 3. Negative calorie adjustment flips bulk ↔ cut intent

**File:** `Calculations/Extensions/CalculateAdjustCalories.swift:13-16`

If `calorieAdjustment = -500`, a "Bulk" goal subtracts 500 (a cut) and "Cut" adds 500 (a bulk). Should use `abs()`.

| Priority | Action                                                                   | Effort  | Status |
| -------- | ------------------------------------------------------------------------ | ------- | ------ |
| 2        | Add `abs()` around calorie adjustment + validate bodyFatPercentage range | ~30 min | Open   |

### 4. Body fat percentage is never validated

**File:** `Calculations/Extensions/CalculationValidatePerson.swift:9-15`

Validation checks age/height/weight for zero but allows any body fat value. A value of 150% produces negative lean body mass and a BMR of ~370 calories silently.

**Fix:** Add range validation (e.g., 2–60) in the existing validator.

| Priority | Action                                                                   | Effort  | Status |
| -------- | ------------------------------------------------------------------------ | ------- | ------ |
| 2        | Add `abs()` around calorie adjustment + validate bodyFatPercentage range | ~30 min | Open   |

### 5. All ViewModels double-conform to `@Observable` and `ObservableObject`

Every model class (`ProfileViewModel`, `SectionManagerViewModel`, `MacroSplitOptionsViewModel`) has both the `@Observable` macro _and_ inherits from `ObservableObject`. These are incompatible observation patterns — if some views use `@State` (Observation framework) and others use `@StateObject` (Combine), they won't stay in sync.

**Fix:** Remove `ObservableObject` inheritance; keep only `@Observable`.

| Priority | Action                                                    | Effort  | Status |
| -------- | --------------------------------------------------------- | ------- | ------ |
| 3        | Remove `ObservableObject` conformance from all ViewModels | ~15 min | Open   |

---

## Important (Correctness & Maintainability)

### 6. Eight redundant `.onChange` handlers on the main page

The main view has eight separate `.onChange` modifiers all calling `recalculate()`. Should be consolidated to a single computed property or one publisher observing all dependencies.

| Priority | Action                                                                   | Effort  | Status |
| -------- | ------------------------------------------------------------------------ | ------- | ------ |
| 5        | Consolidate the 8 `.onChange` calls into one computed property/publisher | ~30 min | Open   |

### 7. Entire file is dead code

`Pages/MacroMixesListPage/MacroMixesListPage.swift` (~50 lines) is fully wrapped in `//` comments and can be safely deleted.

| Priority | Action                                                   | Effort | Status |
| -------- | -------------------------------------------------------- | ------ | ------ |
| 7        | Delete dead code (commented-out file, duplicate V2 view) | ~5 min | Open   |

### 8. Duplicate method in CalculatorTdee.swift

There's a private `adjustForActivityLevel` that is never called — the static version in `Calculator.swift` is the active one. Confusing for anyone editing later.

| Priority | Action                                                 | Effort | Status |
| -------- | ------------------------------------------------------ | ------ | ------ |
| 8        | Remove dead duplicate method from CalculatorTdee.swift | ~5 min | Open   |

### 9. SectionWeight has same check twice (typo)

```swift
model.weight.isNaN || model.weight.isNaN  // should be different validators
```

| Priority | Action                                              | Effort | Status |
| -------- | --------------------------------------------------- | ------ | ------ |
| 9        | Fix repeated .isnan typo in SectionWeight validator | ~5 min | Open   |

### 10. `UIExpanderViewV2` is byte-for-byte identical to `UIExpanderView`

Dead duplication.

| Priority | Action                                                   | Effort | Status |
| -------- | -------------------------------------------------------- | ------ | ------ |
| 7        | Delete dead code (commented-out file, duplicate V2 view) | ~5 min | Open   |

---

## Style & Consistency

### 11. Non-idiomatic naming everywhere

All enums use the `enumXxx` prefix (e.g., `enumActivityLevel`, `enumGender`). Swift convention is just `ActivityLevel`, `Gender`. Files should be renamed accordingly. `EnumDevice.swift` contains a struct, not an enum. Force-unwrapped UUIDs in `FactoryMacroSplits.swift` could use `.uuid()` literals.

| Priority | Action                                | Effort | Status |
| -------- | ------------------------------------- | ------ | ------ |
| 10       | Rename enums to idiomatic Swift style | ~1 hr  | Open   |

### 12. Stale file header comments

At least 8 files have wrong titles in their headers (e.g., `SectionCaloriesAdjusted.swift`'s header says "SectionMaintenanceCalories.swift") — copy-paste artifacts.

| Priority | Action                         | Effort  | Status |
| -------- | ------------------------------ | ------- | ------ |
| 11       | Fix stale file header comments | ~15 min | Open   |

### 13. Picker label typo

`UISegmentCalorieAdjustmentMethodView:15` — the picker's label is literally `"Gender"`. Should be `"Calories"`.

| Priority | Action                                                        | Effort | Status |
| -------- | ------------------------------------------------------------- | ------ | ------ |
| 12       | Fix picker label typo in UISegmentCalorieAdjustmentMethodView | ~5 min | Open   |

### 14. No accessibility labels

No `accessibilityLabel` or `accessibilityValue` on any slider, segment picker, or swipe action across the app. All icon-only buttons are invisible to VoiceOver.

| Priority | Action                                                  | Effort | Status |
| -------- | ------------------------------------------------------- | ------ | ------ |
| 6        | Add `accessibilityLabel` to sliders and segment pickers | ~1 hr  | Open   |

### 15. Magic numbers scattered across 15+ files

Hard-coded values like `100` for safe-area padding, inconsistent spring animation params (`response: 0.3`, `0.45`), opacity `0.85` on red with no explanation — should be centralized constants.

| Priority | Action                                        | Effort  | Status |
| -------- | --------------------------------------------- | ------- | ------ |
| 13       | Centralize magic numbers into named constants | ~45 min | Open   |

---

## Recommended Action Priority

| Priority | Action                                                                   | Effort  | Status       |
| -------- | ------------------------------------------------------------------------ | ------- | ------------ |
| 1        | Fix `CalculateMacros.swift` to use user's actual macro split selection   | ~30 min | **FIXED** ✅ |
| 2        | Add `abs()` around calorie adjustment + validate bodyFatPercentage range | ~30 min | Open ⬜      |
| 3        | Remove `ObservableObject` conformance from all ViewModels                | ~15 min | Open ⬜      |
| 4        | Fix macro normalization overflow using pre-change snapshot               | ~30 min | Open ⬜      |
| 5        | Consolidate the 8 `.onChange` calls into one computed property/publisher | ~30 min | Open ⬜      |
| 6        | Add `accessibilityLabel` to sliders and segment pickers                  | ~1 hr   | Open ⬜      |
| 7        | Delete dead code (commented-out file, duplicate V2 view)                 | ~5 min  | Open ⬜      |
