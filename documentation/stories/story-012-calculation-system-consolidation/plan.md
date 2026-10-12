# Plan: Calculation System Consolidation (Story 012)

## Objective
Consolidate duplicate calculation systems to ensure consistent BMR and TDEE calculations across the application.

## Current State
- `CalculationService` returns 1200 for females (incorrect default)
- `ProfileViewModel.calculateMifflinStJeor()` uses correct female-adjusted formula
- Two entry points: `ProfileViewModel.calculateAllDerivedValues()` and `Calculator.calculate()`

## Decisions
1. **Rename** `calculateAllDerivedValues()` → `refreshResults()`
2. **Remove** `CalculationService.swift` entirely
3. **Use** existing `Calculator` struct with `ProfileViewModel` extensions

## Files to Modify

| File | Action | Reason |
|------|--------|--------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | Modify | Rename method and update to use extensions directly |
| `Services/CalculationService.swift` | Delete | Fully remove duplicate system |
| `SimpleTestTests/SimpleTestTests.swift` | Modify | Update tests to use new calculation methods |

## Implementation Steps

### Step 1: Update ProfileViewModel

**File:** `Models/ProfileViewModel/ProfileViewModel.swift`

**Changes:**
1. Rename `calculateAllDerivedValues()` to `refreshResults()`
2. Remove `CalculationService` imports/usage
3. Call extension methods directly on `self`

**Implementation:**
```swift
func refreshResults() {
    // Use the correct calculation with body fat support
    let bmr: Double
    if self.bodyFatPercentageMethod != .omit, let bodyFat = self.bodyFatPercentage {
        bmr = self.calculateKatchMcArdle(logger: AuditLogger(enabled: false))
    } else {
        bmr = self.calculateMifflinStJeor(logger: AuditLogger(enabled: false))
    }
    
    let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: self.activityLevel, logger: AuditLogger(enabled: false))
    self.tdee = tdee
    self.macroTargets = self.calculateMacros(tdee: tdee)
}

// Add helper method for macro calculation
func calculateMacros(tdee: Double) -> (protein: Int, carbs: Int, fats: Int) {
    let totalCalories = Int(tdee)
    let proteinCal = Double(totalCalories) * 0.4
    let carbCal = Double(totalCalories) * 0.3
    let fatCal = Double(totalCalories) - proteinCal - carbCal
    
    return (
        protein: Int(proteinCal / 4),
        carbs: Int(carbCal / 4),
        fats: Int(fatCal / 9)
    )
}
```

**Note:** The extension methods require an `AuditLogger` parameter. For `refreshResults()`, we can pass a disabled logger since auditing is only needed for the full `Calculator.calculate()` path.

### Step 2: Remove CalculationService

**File:** `Services/CalculationService.swift` - DELETE

This file contains the incorrect female BMR calculation and will be replaced by the consolidated extensions.

### Step 3: Update Tests

**File:** `SimpleTestTests/SimpleTestTests.swift`

All tests using `CalculationService.calculateBMR()` need to be updated:

**Before:**
```swift
let profile = ProfileViewModel(...)
let bmr = CalculationService.calculateBMR(profile: profile)
```

**After:**
```swift
let profile = ProfileViewModel(...)
let bmr = profile.calculateMifflinStJeor(logger: AuditLogger(enabled: false))
```

Update tests for:
- `CalculationServiceBMRTests`
- `CalculationServiceTDEETests`
- `CalculationServiceValidationTests`

## Testing Approach

### Tests to Add/Update
1. **Female BMR test** - Verify female users get correct BMR (not 1200)
2. **Male BMR test** - Verify male BMR matches Mifflin-St Jeor formula
3. **Katch-McArdle test** - Verify body fat calculations work correctly
4. **RefreshResults test** - Verify `refreshResults()` produces same results as `Calculator.calculate()`

### Manual Testing Checklist
- [ ] Female user with valid data gets correct BMR
- [ ] Male user with valid data gets correct BMR
- [ ] User with body fat provided uses Katch-McArdle
- [ ] User with body fat omitted uses Mifflin-St Jeor
- [ ] All activity levels apply correctly
- [ ] Macro targets calculate correctly
- [ ] UI displays correct values

## Rollback Plan
If issues arise:
1. Restore `CalculationService.swift` from git
2. Revert `ProfileViewModel.swift` to previous state
3. Revert test files

## Estimated Impact
- **Lines changed:** ~50 lines in ProfileViewModel
- **Files deleted:** 1 (CalculationService.swift)
- **Tests updated:** ~3 test structs in SimpleTestTests.swift
