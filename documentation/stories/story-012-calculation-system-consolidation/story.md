# Story 012: Calculation System Consolidation

**Objective:** Consolidate duplicate calculation systems to ensure consistent BMR and TDEE calculations across the application.

**Motivation:** There are two separate calculation systems in the codebase that use different formulas for BMR calculation. This is CRITICAL because:
- `CalculationService.calculateBMR()` returns 1200 for females (default value)
- `ProfileViewModel.calculateMifflinStJeor()` uses the correct female-adjusted formula
- This causes incorrect BMR calculations for female users

## Current State

### System 1: CalculationService (used by ProfileViewModel.calculateAllDerivedValues - now refreshResults)
```swift
func refreshResults() {
    let bmr = CalculationService.calculateBMR(profile: self)  // Returns 1200 for females
    let tdee = CalculationService.calculateTdee(bmr: bmr, activityLevel: self.activityLevel)
    self.tdee = tdee
    let macros = CalculationService.calculateMacros(tdee: tdee, profile: self)
    self.macroTargets = (protein: macros.protein, carbs: macros.carbs, fats: macros.fats)
}
```

**CalculationService.calculateBMR()** - Mifflin-St Jeor ONLY, males only:
```swift
guard profile.gender == .male && profile.age > 0 else {
    return 1200.0  // DEFAULT for females - WRONG!
}
```

### System 2: Calculator (used by Calculator.calculate())
```swift
static func calculate(person: ProfileViewModel, createAudit: Bool = false) -> CalculatorResultViewModel {
    let result = CalculatorResultViewModel()
    Calculator.calculateTdee(result: result, person: person, createAudit: createAudit)  // Uses extensions!
    person.calculateMacros(result: result)
    return result
}
```

**ProfileViewModel.calculateMifflinStJeor()** - Correct gender handling:
```swift
let adjustment = self.gender == .male ? 5.0 : -161.0  // DIFFERENT for women!
let bmr = 10.0 * weight + 6.25 * height - 5.0 * age + adjustment
```

## Expected State

- Single source of truth for all calculation logic
- Consistent BMR calculations regardless of which path is used
- Body fat support (Katch-McArdle) available when user has body fat data

## Decisions

### Consolidation Approach

**Use `Calculator` struct with `ProfileViewModel` extensions as the single source.**

**Rationale:**
1. `Calculator.calculateMifflinStJeor()` correctly handles gender-specific formulas
2. `Calculator.calculateKatchMcArdle()` supports body fat percentage calculations
3. Extensions provide clean separation of concerns
4. `CalculatorResultViewModel` provides a clean result structure

### Files to Modify

| File | Change |
|------|--------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | Rename `calculateAllDerivedValues()` to `refreshResults()` and update to use `ProfileViewModel` calculation methods |
| `Services/CalculationService.swift` | **DELETE** (fully removed) |
| `Calculations/Calculator.swift` | Ensure all calculation methods are accessible and complete |
| `Calculations/Extensions/*.swift` | Verify all extensions are properly integrated |
| `MainSectionProfileInput.swift` | Update if uses CalculationService directly |
| Any other file importing CalculationService | Update to use `ProfileViewModel` calculation methods |

## Implementation

### Step 1: Rename and Update ProfileViewModel.calculateAllDerivedValues()

**File:** `Models/ProfileViewModel/ProfileViewModel.swift`

**Rename:** `calculateAllDerivedValues()` → `refreshResults()`

**Implementation:**
```swift
func refreshResults() {
    // Use the correct calculation with body fat support
    let bmr: Double
    if self.bodyFatPercentageMethod != .omit, let bodyFat = self.bodyFatPercentage {
        bmr = self.calculateKatchMcArdle()
    } else {
        bmr = self.calculateMifflinStJeor()
    }
    
    let tdee = self.calculateTDEE(bmr: bmr, activityLevel: self.activityLevel)
    self.tdee = tdee
    self.macroTargets = self.calculateMacros(tdee: tdee)
}
```

### Step 2: Update ProfileViewModel extensions (if needed)

**File:** `Calculations/Extensions/*.swift`

Ensure extensions are accessible from `ProfileViewModel`:

```swift
// In ProfileViewModel+Calculations.swift (or similar)
extension ProfileViewModel {
    func calculateMifflinStJeor() -> Double {
        // Current implementation
    }
    
    func calculateKatchMcArdle() -> Double? {
        // Current implementation - may need to return Optional
    }
    
    func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        // Current implementation
    }
    
    func calculateMacros(tdee: Double) -> (protein: Double, carbs: Double, fats: Double) {
        // Current implementation
    }
}
```

### Step 3: Fully Deprecate CalculationService

**Remove CalculationService entirely** (as per user decision: "fully depreciate remove")

**Action:**
1. Remove the `CalculationService.swift` file
2. Update all callers to use `ProfileViewModel` calculation methods directly
3. Update `Calculator.calculate()` to use the same path as `ProfileViewModel.calculateAllDerivedValues()`

**Migration:**
```swift
// Instead of:
let bmr = CalculationService.calculateBMR(profile: profile)

// Use:
let bmr = profile.calculateMifflinStJeor()
```

## Testing Checklist

### Body Fat Percentage Modes
- [ ] **Auto mode** (`bodyFatPercentageMethod == .auto`): BMR calculated using gender/age/weight/height only (Mifflin-St Jeor)
- [ ] **Omit mode** (`bodyFatPercentageMethod == .omit`): BMR calculated using gender/age/weight/height only (Mifflin-St Jeor)
- [ ] **Provided mode** (`bodyFatPercentageMethod == .manualEntry`): BMR calculated using Katch-McArdle with body fat percentage

### Gender Testing
- [ ] Female users get correct BMR (not 1200 default)
- [ ] Male users get correct BMR
- [ ] BMR values match expected formulas for each gender

### Calculation Consistency
- [ ] TDEE calculations are consistent across all paths
- [ ] Macro calculations are consistent across all paths
- [ ] Both calculation paths produce identical results for same inputs

## Unit Tests

### Body Fat Percentage Mode Tests

#### Auto Mode (`bodyFatPercentageMethod == .auto`)
- [ ] `calculateMifflinStJeor()` returns correct BMR for males
- [ ] `calculateMifflinStJeor()` returns correct BMR for females
- [ ] `calculateKatchMcArdle()` returns `nil` or falls back to Mifflin-St Jeor
- [ ] Expected: BMR calculated using gender/age/weight/height only (Mifflin-St Jeor)

#### Omit Mode (`bodyFatPercentageMethod == .omit`)
- [ ] `calculateMifflinStJeor()` returns correct BMR for males
- [ ] `calculateMifflinStJeor()` returns correct BMR for females
- [ ] `calculateKatchMcArdle()` returns `nil` or falls back to Mifflin-St Jeor
- [ ] Expected: BMR calculated using gender/age/weight/height only (Mifflin-St Jeor)

#### Manual Entry Mode (`bodyFatPercentageMethod == .manualEntry`)
- [ ] `calculateKatchMcArdle()` returns correct BMR when body fat is provided
- [ ] `calculateMifflinStJeor()` still returns Mifflin-St Jeor value for comparison
- [ ] Expected: BMR calculated using Katch-McArdle formula with body fat percentage

### Mifflin-St Jeor Formula Tests (all body fat modes)
- [ ] **Male formula:** `BMR = 10*weight + 6.25*height - 5*age + 5`
  - [ ] Test case: Male, 30 years, 180cm, 75kg → Expected: 1743.75
  - [ ] Test case: Male, 25 years, 175cm, 70kg → Expected: 1713.75
- [ ] **Female formula:** `BMR = 10*weight + 6.25*height - 5*age - 161`
  - [ ] Test case: Female, 30 years, 165cm, 65kg → Expected: 1422.25
  - [ ] Test case: Female, 25 years, 160cm, 60kg → Expected: 1360.0

### Katch-McArdle Formula Tests
- [ ] **Formula:** `BMR = 370 + 21.6 * LBM` where `LBM = weight * (1 - bodyFat/100)`
- [ ] Test case: 70kg, 20% body fat → LBM = 56kg → Expected BMR = 1585.6
- [ ] Test case: 60kg, 25% body fat → LBM = 45kg → Expected BMR = 1348.0
- [ ] Test case: 80kg, 15% body fat → LBM = 68kg → Expected BMR = 1844.8

### TDEE Tests (all activity levels)
- [ ] Sedentary: `TDEE = BMR * 1.2`
- [ ] Light exercise: `TDEE = BMR * 1.375`
- [ ] Moderate exercise: `TDEE = BMR * 1.55`
- [ ] Active: `TDEE = BMR * 1.725`
- [ ] Very active: `TDEE = BMR * 1.9`

### Macro Split Tests
- [ ] Protein: `tdee * 0.3 / 4` (30% of calories / 4 cal per gram)
- [ ] Carbs: `tdee * 0.4 / 4` (40% of calories / 4 cal per gram)
- [ ] Fats: `tdee * 0.3 / 9` (30% of calories / 9 cal per gram)

### Edge Cases
- [ ] Age = 0 (infant)
- [ ] Height = 0
- [ ] Weight = 0
- [ ] Body fat = 0
- [ ] Body fat = 100
- [ ] Negative values (should validate or handle gracefully)

## Dependencies

None - this is a standalone refactoring. However, the following stories should be reviewed for compatibility:
- Story 003: Macro Options Navigation (uses macro calculations)
- Story 011: Focus Management (uses calculation results)

## Open Questions

1. **CalculationService removal** - Fully remove the file, or keep it as a deprecated wrapper? **Decision: Fully remove.**

2. **ProfileViewModel.calculateAllDerivedValues() naming** - The current name `calculateAllDerivedValues()` is misleading because:
   - It doesn't calculate "all" derived values (body fat is calculated but not output)
   - It's a UI-triggered update method, not a pure calculation function
   
   **Decision:** Rename to `updateCalculations()` or `refreshResults()` to better reflect its purpose.

3. **Unit tests** - Add comprehensive unit tests for all calculation formulas:
   - Mifflin-St Jeor (male and female)
   - Katch-McArdle
   - TDEE with all activity levels
   - Macro splitting
   - Edge cases and boundary values
