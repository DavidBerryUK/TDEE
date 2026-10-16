# Story 015: Share Results

**Objective:** Implement a functional share button that allows users to share their calculation results via iOS share sheet (ActivityViewController).

**Motivation:** Users want to share their calculation results (BMR, TDEE, macros) with others - for example, to share with a nutritionist, friend, or social media. The current share button is non-functional.

## Current State

```swift
ToolbarItem(placement: .topBarTrailing) {
    Button {
    } label: {
        Image(systemName: "square.and.arrow.up")
    }
    .accessibilityLabel("Share current settings")
}
```

The button:
- Shows a share icon (square with up arrow)
- Has accessibility label "Share current settings"
- Has no action when tapped

## Previous Approach: Audit Functionality

The audit functionality was considered but deemed:
- **Crude** - Audit is designed for calculation tracing, not user-facing sharing
- **Hard to maintain** - Audit format is technical and not user-friendly
- **Incorrect purpose** - Audit items are key-value pairs for developers, not a polished share format

## New Approach: ShareResultsModel

A dedicated `ShareResultsModel` struct provides:
- **Clean separation** - Calculation logic separate from share functionality
- **Pre-formatted text** - Human-readable descriptions for all data
- **Easy to test** - Simple struct with no side effects
- **Maintainable** - Clear mapping between profile/result data and share output

### ShareResultsModel Features

**Input Data (pre-formatted):**
- Gender: "Male" / "Female"
- Age: "25 years"
- Height: "175 cm"
- Weight: "70 kg"
- Activity Level: "Low activity" (with full description)
- Body Fat: "15%" or "N/A" (if omitted)
- Calorie Adjustment: "Maintain" with adjustment amount
- Macro Split Method: "Ketogenic" / "Low Carb" / etc.
- Macro Preset: "Balanced" / "Diet" / etc.

**Output Data (pre-formatted):**
- BMR: "1850 kcal/day"
- TDEE: "2400 kcal/day"
- Adjusted Calories: "2200 kcal/day"
- Macro Targets: Formatted with grams and percentages

**Share Text:**
A complete formatted summary ready for ActivityViewController.

### ShareResultsModel Initializer

The model requires macro method and preset names to be passed explicitly. Since `MacroSplitOptionModel` only has a `name` property, both parameters will have the same value (the preset name).

```swift
init(
    profile: ProfileViewModel,
    result: CalculatorResultViewModel,
    macroMethodName: String = "Custom",
    macroPresetName: String = "Custom"
)
```

To populate these values, call `ProfileViewModel.createShareResultsModel(result:)` which:
1. Queries `MacroSplitOptionsModelCollection` for the selected macro preset
2. Extracts `name` from the selected option (or "Custom" if not found)
3. Returns a fully populated ShareResultsModel

## Expected Behavior

- Tapping the share button creates a `ShareResultsModel` from current profile and results
- ActivityViewController is presented with the share text
- Users can share via Messages, Mail, Notes, or other sharing options
- The app remains responsive during and after sharing
- Share button is only enabled when valid calculation results exist

## Implementation Plan

### 1. ShareResultsModel (Already Created)
**File:** `Models/ShareResultsModel.swift`

A struct containing all pre-formatted shareable data with:
- Input data properties (gender, age, height, weight, activity, etc.)
- Output data properties (BMR, TDEE, adjusted calories, macros)
- `shareText` computed property for the formatted summary
- Initializer taking `ProfileViewModel`, `CalculatorResultViewModel`, `macroMethodName`, and `macroPresetName`

### 2. Integrate into ProfileViewModel
**File:** `Models/ProfileViewModel/ProfileViewModel.swift`

Add a method to create a share model with macro preset lookup:

```swift
func createShareResultsModel(result: CalculatorResultViewModel) -> ShareResultsModel {
    let macroCollection = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
    let selectedMacro = macroCollection.items.first(where: { $0.id == selectedMacroId })
    
    return ShareResultsModel(
        profile: self,
        result: result,
        macroMethodName: selectedMacro?.name ?? "Custom",
        macroPresetName: selectedMacro?.name ?? "Custom"
    )
}
```

**Important:** `MacroSplitOptionModel` only has a `name` property (e.g., "Balanced", "Ketogenic"). The `methodName` and `presetName` parameters in `ShareResultsModel` both use the preset's name.

### 3. Implement Share Action in UIMainView
**File:** `Pages/MainPage/UIMainView.swift`

Since UIMainView is a pure SwiftUI View without UIViewController access, add a presentation handler:

1. Add `presentationHandler` parameter to UIMainView
2. Add share button to toolbar:
```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button {
            guard profile.isValid else { return }
            let shareModel = profile.createShareResultsModel(result: calculationResult)
            presentationHandler?(shareModel.shareText)
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Share calculation results")
        .disabled(!profile.isValid)
    }
}
```

3. In parent view (ContentView), provide presentation handler that creates and presents UIActivityViewController

### 4. Add Tests
**File:** `SimpleTestTests/ShareResultsModelTests.swift`

- Verify gender is correctly formatted ("Male", "Female")
- Verify activity level descriptions are correct
- Verify BMR, TDEE, and macro values are formatted with units
- Verify share text contains all expected sections

## Files to Create/Modify

| File | Action |
|------|--------|
| `Models/ShareResultsModel.swift` | Already exists - review and verify |
| `Models/ProfileViewModel/ProfileViewModel.swift` | **Modify** - Add `createShareResultsModel()` method |
| `Pages/MainPage/UIMainView.swift` | **Modify** - Add share button with presentation handler |
| `SimpleTestTests/ShareResultsModelTests.swift` | **Create** - Unit tests for model |

## Testing Checklist

### Unit Tests (ShareResultsModel)
- [ ] Gender formatted as "Male" / "Female"
- [ ] Age formatted with "years" suffix
- [ ] Height/weight formatted with units (cm/kg)
- [ ] Activity level description mapped correctly
- [ ] Body fat shows percentage or "N/A"
- [ ] Calorie adjustment shows method and amount (or "None")
- [ ] Macro split method and preset names from selected macro
- [ ] BMR/TDEE/adjusted calories with "kcal/day" suffix
- [ ] Macro targets with grams and percentages
- [ ] `shareText` contains all sections

### Integration Tests
- [ ] `createShareResultsModel()` looks up macro preset correctly
- [ ] Share button only visible when `profile.isValid`
- [ ] Share button disabled when calculation invalid
- [ ] Tapping share presents ActivityViewController
- [ ] Share sheet can be dismissed without action
- [ ] Share text contains all expected sections
- [ ] App remains responsive after sharing
- [ ] Accessibility label is present and accurate

## Dependencies

None - this is a standalone feature.
