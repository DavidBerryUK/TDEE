# Plan: Share Results (Story 015)

## Overview

This plan implements a functional share button that allows users to share their calculation results (BMR, TDEE, macros) via iOS share sheet.

## Known Issues / clarifications from Story Review

1. **ShareResultsModel already exists** - Model is complete with all formatters
2. **UIMainView is SwiftUI only** - Cannot directly call `present()` on UIViewController; requires a UIViewControllerRepresentable wrapper or parent view controller passed as a binding
3. **Macro preset lookup required** - `ProfileViewModel.createShareResultsModel()` must query `MacroSplitOptionsModelCollection` to get `methodName` and `presetName` from `selectedMacroId`

## Approach: Three-Part Implementation

### Part A: ProfileViewModel Integration

**Goal:** Add `createShareResultsModel()` method to `ProfileViewModel`.

#### Tasks:

1. **Add import statements to `ProfileViewModel.swift`**
   ```swift
   import MacroSplitOptionsModelCollection  // For preset lookup
   import FactoryMacroSplits                // For macro options
   ```

2. **Add `createShareResultsModel()` method to `ProfileViewModel`**
   - Location: `Models/ProfileViewModel/ProfileViewModel.swift`
   - Signature: `func createShareResultsModel(result: CalculatorResultViewModel) -> ShareResultsModel`
   - Lookup selected macro preset using `MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())`
   - Extract `methodName` and `presetName` from selected option (or "Custom" if not found)
   - Returns fully populated `ShareResultsModel` with macro details

3. **Verify existing `ShareResultsModel` initializer**
   - Confirm it accepts `macroMethodName` and `macroPresetName` parameters
   - Verify all formatters produce user-friendly output

### Part B: Share Button Implementation (UIMainView)

**Goal:** Add share button to UIMainView with proper presentation handling.

#### Challenges:
- `UIMainView` is a pure SwiftUI View (no UIViewController access)
- `UIActivityViewController` requires a UIViewController to present
- Need to bridge SwiftUI to UIKit presentation context

#### Options Considered:

**Option 1: Pass UIViewController from parent (RECOMMENDED)**
- Modify `UIMainView` to accept a presentation handler closure
- Parent view (ContentView/HostingViewController) provides presentation logic
- Clean separation of concerns

**Option 2: UIViewControllerRepresentable wrapper**
- Create a SwiftUI wrapper around ActivityViewController
- More complex but fully SwiftUI-native approach
- Better for reuse

**Option 3: Present from ContentView**
- Add share button to `ContentView` instead of `UIMainView`
- Share button has access to `navigationItem` for popover presentation
- May be less intuitive for user (button not near calculation results)

#### Implementation (Option 1):
1. Add `presentationHandler` parameter to `UIMainView`
2. Create share button in toolbar
3. Handler creates `ShareResultsModel` and presents `UIActivityViewController`

### Part C: Unit Tests

**Goal:** Verify `ShareResultsModel` formatting logic.

#### Tasks:

1. **Create `ShareResultsModelTests.swift`**
   - Location: `SimpleTestTests/ShareResultsModelTests.swift`
   - Test each formatter independently

2. **Test cases:**
   - Gender text: "Male", "Female"
   - Age text: "25 years"
   - Height/weight with units (cm/kg)
   - Activity level descriptions
   - Body fat: formatted percentage or "N/A"
   - Calorie adjustment: method + amount (or "None")
   - Macro split method and preset names
   - BMR, TDEE, adjusted calories with "kcal/day" suffix
   - Macro targets: grams and percentages
   - Complete `shareText` content verification

## Files to Modify

| File | Change |
|------|--------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | Add `createShareResultsModel()` method with macro lookup |
| `Models/ProfileViewModel/ProfileViewModel.swift` | Add imports for `MacroSplitOptionsModelCollection`, `FactoryMacroSplits` |
| `Pages/MainPage/UIMainView.swift` | Add share button with presentation handler |
| `SimpleTestTests/ShareResultsModelTests.swift` | Create unit tests for model |

## Testing Strategy

1. **Unit tests (Part A):**
   - Test each field formatter individually
   - Test `shareText` includes all sections
   - Test edge cases (empty body fat, zero adjustment, no macro preset)

2. **Integration tests (Part B):**
   - Test share button visibility conditions (`profile.isValid`)
   - Test ActivityViewController presentation via handler

## Success Criteria

- [ ] Share button visible in toolbar when `profile.isValid`
- [ ] `createShareResultsModel()` correctly looks up macro preset
- [ ] Tapping share presents ActivityViewController
- [ ] Share text contains all expected sections (inputs, outputs, macros)
- [ ] All text is user-friendly (not technical audit format)
- [ ] Tests pass for all parts
