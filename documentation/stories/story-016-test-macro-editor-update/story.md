# Story 016: Test Macro Editor Update

**Objective:** Verify that when a user selects a macro mix, edits it, and saves it, the main screen properly updates to display the new values.

**Motivation:** Currently, when a user edits a macro preset and returns to the main screen, the displayed values do not refresh to show the updated macro mix. This creates a confusing user experience where changes appear to not be saved or applied.

**Current State:**
- User can select a macro mix from the Macro Split section
- User can edit the selected macro mix (e.g., adjust protein, carbs, fat percentages)
- User can save the edited macro mix
- Upon returning to the main screen, the macro values shown are the OLD values before editing
- A manual refresh or navigation away and back is required to see the updated values

**Expected Behavior:**
- When a macro mix is edited and saved, the main screen should automatically reflect the new values
- No manual refresh should be required
- The update should happen seamlessly when the user returns to the main screen

**Current Implementation Details:**

### Macro Mix Editor Flow
1. **UIMainView** -> Taps Macro Split section -> Navigates to macro options
2. **MacroOptionsView** -> Selects a macro -> Navigates to macro editor
3. **MacroEditorView** -> Edits values -> Saves

### Data Flow
- ProfileViewModel holds current macro targets
- Macro mix editor modifies a stored macro preset
- Changes persist to SwiftData
- Main screen does NOT refresh when returning

**Files to Investigate:**
| File | Purpose |
|------|---------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | Holds macro targets, needs update notification |
| `Pages/MainPage/UIMainView.swift` | Main screen that displays macro values |
| `Pages/MacroOptions/MacroOptionsView.swift` | Macro options list and navigation |
| `Pages/MacroEditor/MacroEditorView.swift` | Macro mix editor |
| `Models/MacroModel.swift` | Macro preset data model |

**Implementation Approach:**
1. Identify why the main screen doesn't receive update notifications
2. Implement either:
   - **Option A:** Use `@Published` properties or `ObservableObject` to trigger UI updates
   - **Option B:** Use `onChange` modifiers to detect macro changes
   - **Option C:** Re-fetch macro data when navigating back to main screen

**Testing Checklist:**
- [ ] Select an existing macro mix
- [ ] Edit the macro percentages (protein, carbs, fat)
- [ ] Save the changes
- [ ] Return to main screen
- [ ] Verify macro values display the updated percentages
- [ ] Verify BMR and TDEE recalculate correctly with new macros
- [ ] Test with multiple different macro mixes
- [ ] Test editing and saving multiple times in a row

**Dependencies:** None - standalone fix

**Related Issues:** 
- May be related to SwiftUI view lifecycle and data binding
- May require `@StateObject` vs `@ObservedObject` review
