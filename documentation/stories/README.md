# Stories

This directory contains user stories for the SimpleTest iOS project.

## Story Status

| # | Title | Status |
|---|-------|--------|
| 001 | Simulator/Device Configuration | Done |
| 002 | Macro Split Visibility | Done |
| 003 | Navigate from Macro Split to Macro Options | Done |
| 004 | Main Screen Polish | Done |
| 005 | Result Card Styling | Done |
| 006 | Macro Picker Label | Done |
| 007 | Share Button Fix | Done |
| 008 | Toolbar Background Fix | Done |
| 009 | Section Spacing Consistency | Done |
| 010 | Animation Performance | Done |
| 011 | Focus Management | Done |
| 012 | Calculation System Consolidation | Done |
| 013 | Align Macro Model With Profile View | Done |
| 014 | SwiftData Persistence | Done |
| 015 | Share Results | Done |
| 016 | Test Macro Editor Update | Done |
| 017 | SwiftData Persistence Fixes | Done |
| 018 | Themes | Done |
| 019 | Dynamic Type Section Rows | Done |
| 020 | Apple Watch App | Done |
| 021 | Multiple Profiles | Done |
| 022 | iPad Adaptation | Done |

## Story 015: Share Results

**Objective:** Implement a functional share button that allows users to share their calculation results via iOS share sheet (ActivityViewController).

**Motivation:** Users want to share their calculation results (BMR, TDEE, macros) with others - for example, to share with a nutritionist, friend, or social media. The current share button is non-functional.

**Current State:**
- Share button shows a share icon (square with up arrow)
- Has accessibility label "Share current settings"
- Has no action when tapped

**Implementation Plan:**
1. **ShareResultsModel** (`Models/ShareResultsModel.swift`) - Already exists with formatters for all data
2. **ProfileViewModel** - Add `createShareResultsModel(result:)` method to look up macro preset and create share model
3. **UIMainView** - Add share button with presentation handler for UIActivityViewController

**Key Decisions:**
- Use `MacroSplitOptionsModelCollection` to look up macro preset name from `selectedMacroId`
- Pass presentation handler from parent view since UIMainView is pure SwiftUI

**Files to Modify:**
| File | Change |
|------|--------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | Add `createShareResultsModel()` with macro lookup |
| `Pages/MainPage/UIMainView.swift` | Add share button with presentation handler |
| `SimpleTestTests/ShareResultsModelTests.swift` | Create unit tests |

**Dependencies:** None - standalone feature

---

## Story 001: Simulator/Device Configuration

**Objective:** Add a configuration system that provides different default values based on whether the app is running on a simulator or a physical device.

**Motivation:** When developing iOS apps, it's common to want different default values in the simulator (e.g., preset test data) versus on a physical device (e.g., empty fields requiring user input).

**Open Questions:**
- Should the configuration be loadable at runtime, or compile-time via build settings?
- Should the config be bundled with the app, or loadable from a remote source?

**Configuration Keys:**
| Key | Simulator Default | Device Default |
|-----|------------------|----------------|
| Gender | `.male` | `.male` |
| Age | 25 | 16 |
| Height | 175.0 cm | 0.0 cm |
| Weight | 70.0 kg | 0.0 kg |
| Activity Level | `.moderateExercise` | `.sedentary` |
| Body Fat Percentage | 15.0% | 0.0% |

**Decisions:**
- Configuration format: Swift struct with `#if targetEnvironment(simulator)` compiler directive
- Storage: Hardcoded values (no external files needed initially)

**Depends on:** None

---

## Story 002: Macro Split Visibility

**Objective:** Ensure the macro readout is visible when expanding the Macro Split section. Currently, details are off the bottom of the screen.

**Motivation:** Users need to see their macro breakdown (protein, carbs, fat) when they expand the Macro Split view to understand their nutritional targets.

**Current Behavior:**
- Tapping Macro Split expands to show macro details
- Details are positioned below the visible screen area
- User cannot scroll to see the full macro breakdown

**Expected Behavior:**
- Macro Split expands within visible area
- Macro readout (protein, carbs, fat values) is fully visible
- User can interact with macro values if needed

**Open Questions:**
- Should the expansion be animated?
- Should scrolling be enabled within the expanded view?

**Implementation Notes:**
- Review `MacroSplitView` or similar macro-related view
- Consider using `ScrollView` if content exceeds available space
- Ensure layout adapts to different screen sizes

**Depends on:** None

---

## Story 003: Navigate from Macro Split to Macro Options

**Objective:** Add a way to navigate from the expanded Macro Split section to the Macro Options list where users can view, add, and edit custom macro presets.

**Motivation:** Users need an easy way to access the macro mixer and manage their custom macro presets without having to use the settings menu. The Macro Split section is where users interact with macros daily, so it makes sense to provide direct access to the full macro configuration from there.

**Current Behavior:**
- Macro Split section shows current macro selection via a picker wheel
- Macro Options list (accessible via Settings > Maintain Macros) lists all available presets
- No direct navigation from Macro Split section to Macro Options
- Users must go through Settings to manage custom macros

**Expected Behavior:**
- Tapping the Macro Split section header (or a chevron icon) navigates to the Macro Options list
- From the Macro Options list, users can:
  - View all available macro presets
  - Add new custom macros using the mixer
  - Edit existing macros
- Changes to macro presets are immediately available in the Macro Split picker

**Open Questions:**
- Should the navigation be from the section header or a dedicated button?
- Should the section expand when tapped, or does navigation take precedence?

**Decisions:**
- Add a chevron/right arrow icon to the right side of the Macro Split section title
- Tapping the title area or chevron navigates to the Macro Options list
- Keep expansion behavior for the section (toggle detail view)

**Depends on:** None

---

## Story 012: Calculation System Consolidation

**Objective:** Consolidate duplicate calculation systems to ensure consistent BMR and TDEE calculations across the application.

**Motivation:** There are two separate calculation systems in the codebase that use different formulas for BMR calculation. This is CRITICAL because:
- `CalculationService.calculateBMR()` returns 1200 for females (default value)
- `ProfileViewModel.calculateMifflinStJeor()` uses the correct female-adjusted formula
- This causes incorrect BMR calculations for female users

### Current State

#### System 1: CalculationService (used by ProfileViewModel.calculateAllDerivedValues)
```swift
func calculateAllDerivedValues() {
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

#### System 2: Calculator (used by Calculator.calculate())
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

### Expected State

- Single source of truth for all calculation logic
- Consistent BMR calculations regardless of which path is used
- Body fat support (Katch-McArdle) available when user has body fat data

### Decisions

#### Consolidation Approach

**Use `Calculator` struct with `ProfileViewModel` extensions as the single source.**

**Rationale:**
1. `Calculator.calculateMifflinStJeor()` correctly handles gender-specific formulas
2. `Calculator.calculateKatchMcArdle()` supports body fat percentage calculations
3. Extensions provide clean separation of concerns
4. `CalculatorResultViewModel` provides a clean result structure

#### Files to Modify

| File | Change |
|------|--------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | Update `calculateAllDerivedValues()` to use `Calculator.calculateMifflinStJeor()` instead of `CalculationService.calculateBMR()` |
| `Services/CalculationService.swift` | Either deprecate or update to delegate to `Calculator` |
| `Calculations/Calculator.swift` | Ensure all calculation methods are accessible and complete |
| `Calculations/Extensions/*.swift` | Verify all extensions are properly integrated |

### Implementation

#### Step 1: Update ProfileViewModel.calculateAllDerivedValues()

**File:** `Models/ProfileViewModel/ProfileViewModel.swift`

**Current:**
```swift
func calculateAllDerivedValues() {
    let bmr = CalculationService.calculateBMR(profile: self)
    let tdee = CalculationService.calculateTdee(bmr: bmr, activityLevel: self.activityLevel)
    self.tdee = tdee
    let macros = CalculationService.calculateMacros(tdee: tdee, profile: self)
    self.macroTargets = (protein: macros.protein, carbs: macros.carbs, fats: macros.fats)
}
```

**Proposed:**
```swift
func calculateAllDerivedValues() {
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

#### Step 2: Update ProfileViewModel extensions (if needed)

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

#### Step 3: Consider deprecating CalculationService

**Option A:** Deprecate with warnings
```swift
@available(*, deprecated, message: "Use ProfileViewModel calculation methods instead")
extension CalculationService {
    // Keep for backwards compatibility but mark deprecated
}
```

**Option B:** Update to delegate to Calculator
```swift
static func calculateBMR(profile: ProfileViewModel) -> Double {
    return profile.calculateMifflinStJeor()
}
```

### Testing Checklist

- [ ] Female users get correct BMR (not 1200 default)
- [ ] Male users get correct BMR
- [ ] Users with body fat data get Katch-McArdle BMR
- [ ] Users without body fat data get Mifflin-St Jeor BMR
- [ ] TDEE calculations are consistent
- [ ] Macro calculations are consistent
- [ ] Both calculation paths produce identical results for same inputs
- [ ] Existing tests still pass

### Dependencies

None - this is a standalone refactoring.

### Open Questions

1. Should we keep `CalculationService` at all, or fully deprecate it?
2. Should `ProfileViewModel.calculateAllDerivedValues()` be renamed or documented as the "preferred" path?
3. Should we add unit tests to verify both systems produce identical results?

---

## Story 016: Macro Editor Navigation & Update Flow

**Objective:** Improve the macro editor navigation flow so users can edit their current macro mix directly without having to navigate through the options list, while still providing access to manage the full list of presets. Also verify that the main screen updates correctly after saving changes.

**Motivation:** The current navigation flow is clunky:
1. User taps Macro Split section -> goes to Macro Options list
2. User selects a macro -> goes to Macro Editor
3. User saves changes -> returns to Macro Options list
4. User must navigate back AGAIN to return to Main Screen

This two-step navigation back is frustrating. Users primarily want to edit their CURRENT macro mix, not browse the entire list.

**Current State:**
- Macro Split section only shows the currently selected macro
- Tapping opens the full Macro Options list (all presets)
- User must navigate through list to find their macro
- After saving, user returns to list, not main screen
- Main screen does not update after saving changes

**Expected Behavior:**
- Tapping Macro Split section shows a quick menu with two options:
  - **"Edit Current Macro"** -> Directly edit the currently selected macro, save returns to Main Screen
  - **"Manage Macro Presets"** -> Browse full list, save returns to list
- When a macro mix is edited and saved, the main screen should automatically reflect the new values
- No manual refresh should be required

**Implementation Approach:**

### Option A: Action Sheet / Popover Menu
When user taps Macro Split section:
```
┌─────────────────────────────┐
│  Edit Current Macro         │
│  ( Edits active mix )      │
├─────────────────────────────┤
│  Manage Macro Presets       │
│  ( Browse full list )      │
├─────────────────────────────┤
│  [ Cancel ]                 │
└─────────────────────────────┘
```

### Option B: Two-Tap Flow
1. Tap Macro Split -> Shows inline quick-edit (just the current macro values)
2. Long press or tap "Manage" -> Opens full options list

### Option C: Smart Navigation
- First tap of Macro Split: Edit current macro directly
- Navigation back from editor: Returns to Main Screen
- Separate "Manage Presets" button (e.g., chevron icon) -> Opens full list

**Files to Investigate/Modify:**
| File | Change |
|------|--------|
| `Pages/MainPage/UIMainView.swift` | Add navigation menu for macro mix |
| `Pages/MacroOptions/MacroOptionsView.swift` | Keep existing list view |
| `Pages/MacroEditor/MacroEditorView.swift` | Add "save & return to main" option |
| `Models/MacroModel.swift` | May need update to support inline editing |

**Testing Checklist:**
- [ ] Tap Macro Split shows menu (or inline editor)
- [ ] Edit current macro saves and returns to Main Screen
- [ ] Macro values update correctly after save
- [ ] "Manage Presets" option shows full list
- [ ] List shows all available macros
- [ ] Editing from list still works as before
- [ ] Changes persist across app restarts

**Dependencies:** None - standalone improvement

**Related Issues:**
- May be related to SwiftUI view lifecycle and data binding
- May require `@StateObject` vs `@ObservedObject` review

---

## Story 018: Themes

See [story-018-themes/story.md](story-018-themes/story.md).
