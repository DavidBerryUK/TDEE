# Story 016: Macro Editor Navigation & Update Flow

**Objective:** Improve the macro editor navigation flow so users can edit their current macro mix directly without having to navigate through the options list, while still providing access to manage the full list of presets. Also verify that the main screen updates correctly after saving changes.

**Motivation:** The current navigation flow is clunky:
1. User taps Macro Split section -> goes to Macro Options list
2. User selects a macro -> goes to Macro Editor
3. User saves changes -> returns to Macro Options list
4. User must navigate back AGAIN to return to Main Screen

This two-step navigation back is frustrating. Users primarily want to edit their CURRENT macro mix, not browse the entire list.

---

## Current Code Analysis

### Navigation Flow
```
UIMainView (Main Screen)
    ↓ taps "Customise" button in SectionMacroSplit
MacroOptionsListViewPage (Options List)
    ↓ taps a macro card or swipe-edit
MacroEditViewPage (Editor)
    ↓ saves
Back to MacroOptionsListViewPage (List)
    → User must tap back AGAIN to return to Main Screen
```

### Key Files

| File | Role | Key Observations |
|------|------|------------------|
| `SectionMacroSplit.swift` | Section view | Has "Customise" button that navigates to `.maintainMacroConfig` |
| `MacroOptionsListViewPage.swift` | Options list | Shows all presets; `handleOnSelect` navigates back after selection |
| `MacroEditViewPage.swift` | Editor | `dismiss()` on save, returns to previous screen (the list) |
| `UISectionSummaryValueMacroMix.swift` | Display | Shows selected macro name, uses `collection.items` |
| `ProfileViewModel.swift` | State | `selectedMacroId` triggers `syncSelectedMacro()` which reads from `MacroSplitOptionsModelCollection` |

### Data Flow Issue
The main screen **does** recalculate when `selectedMacroId` changes:
```swift
// UIMainView.swift:118-120
.onChange(of: profile.selectedMacroId) { _, _ in
    Task { await recalculate() }
}
```

**However**, when editing a preset:
1. `MacroEditViewPage` edits a clone of the `MacroSplitOptionModel`
2. On save, `collection.update(editMacro)` updates the collection
3. The `ProfileViewModel.selectedMacroId` **does not change** - same UUID
4. The collection updates but the main screen has no `onChange` for collection changes

---

## UX Analysis & Recommendations

### Problem 1: Indirect Selection Flow
**Current:** Macro Split section → Options List → Editor

**Issue:** Users want to edit their CURRENT macro, but the flow forces them to:
1. Navigate to the list first
2. Find their macro in the list
3. Then edit it

**Recommendation:** **Option C (Smart Navigation)** is optimal:
- Tapping the Macro Split section directly opens the editor for the currently selected macro
- A separate "Manage" affordance (e.g., chevron icon, or "Manage Presets" button) opens the full list
- This is the most intuitive for the common case while preserving access to list management

### Problem 2: Two-Step Return Navigation
**Current:** Save → Returns to List → Must tap back again

**Issue:** The editor's `dismiss()` navigates back to the navigation destination that called it (the list), not directly to the main screen.

**Recommendation:** Add a **"Save & Return to Main"** option:
- Keep the existing "Save" button that returns to list (for power users who want to edit multiple)
- Add a "Done" button that saves AND dismisses all the way back to main screen
- Use a different navigation path or pass a return destination parameter

### Problem 3: UI Not Updating After Edit
**Current:** Editing a preset doesn't trigger main screen refresh

**Issue:** `ProfileViewModel.selectedMacroId` doesn't change when editing, so no recalculation happens.

**Recommendation:** Two-part fix:
1. **Short-term:** Add `onChange` for the macro collection in `UIMainView` to trigger recalculation when presets are updated
2. **Long-term:** Make the macro preset editing modify the selected preset in-place, which will trigger the UI to refresh

---

## Recommended Implementation (UX-Optimal)

### Approach: Split-Action Navigation

When user taps the "Macro Split" section header or the "Customise" button:

```
┌─────────────────────────────────────────┐
│  Macro Mix                              │
├─────────────────────────────────────────┤
│  Current: Balanced (30/40/30)           │
│                                         │
│  [Edit Current Macro]  ← Primary        │
│  (Edits currently selected preset)      │
│                                         │
│  [Manage Macro Presets]                 │
│  (View and edit all presets)            │
│                                         │
│  [Cancel]                               │
└─────────────────────────────────────────┘
```

### Implementation Details

#### 1. Main Section Macro Mix - Add Menu
**File:** `SectionMacroSplit.swift`

Replace the single "Customise" button with a menu that presents two options:

```swift
// Add a menu for dual-purpose navigation
Menu {
    Button("Edit Current Macro") {
        // Navigate directly to edit current macro
        path.append(.macroEditorEdit(currentMacroOption))
    }
    Button("Manage Presets") {
        // Navigate to full list
        path.append(.maintainMacroConfig)
    }
} label: {
    Text("Customise")
        .foregroundColor(.accentColor)
        .font(.body.weight(.semibold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal)
}
```

#### 2. Editor - Add "Done" Button
**File:** `MacroEditViewPage.swift`

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button("Done") {
            collection.update(editMacro)
            // Dismiss all the way back to main screen
            // By popping to root or using a callback
            dismiss()
        }
        .disabled(
            editMacro.name.isEmpty ||
            (editMacro.protein + editMacro.carbs + editMacro.fats) != 100
        )
    }
    
    ToolbarItem(placement: .topBarLeading) {
        Button("Cancel") {
            dismiss()
        }
    }
}
```

#### 3. Main Screen - Add Collection Observation
**File:** `UIMainView.swift`

Add observation for macro collection changes:

```swift
.onChange(of: globalMacroCollection.items) { _, _ in
    Task { await recalculate() }
}
```

This ensures the main screen refreshes when any macro preset is modified.

---

## Alternative Considered (and Rejected)

### Option A: Action Sheet (Rejected)
- **Why:** Adds an extra tap for the most common action
- **Issue:** Users have to tap "Edit Current Macro" then edit, vs just tapping to edit directly

### Option B: Inline Editing (Rejected)
- **Why:** Would require significant UI restructuring
- **Issue:** Modifying the wheel picker in-place is not intuitive; users expect to see percentage sliders

### Option C: Smart Navigation (RECOMMENDED)
- **Why:** Direct access to most common action while preserving full management
- **Benefit:** Single tap to edit current, separate affordance for list management

---

## Updated Story Requirements

### User Flow (After Implementation)

```
Scenario 1: Quick Edit Current Macro
1. User taps "Customise" button in Macro Split section
2. Menu appears with "Edit Current Macro" and "Manage Presets"
3. User taps "Edit Current Macro"
4. Editor opens with current macro's values
5. User edits and taps "Done"
6. Returns directly to Main Screen
7. Macro values update automatically

Scenario 2: Edit from List / Manage Presets
1. User taps "Customise" → "Manage Presets"
2. Options list shows all presets
3. User swipes or taps to edit a preset
4. User edits and taps "Save"
5. Returns to Options List
6. User taps back to return to Main Screen
```

---

## Files to Modify

| File | Change |
|------|--------|
| `SimpleTest/ViewSections/SectionMacroSplit.swift` | Replace single button with dual-option menu |
| `SimpleTest/Pages/MacroEditPage/MacroEditViewPage.swift` | Add "Done" button that dismisses all the way |
| `SimpleTest/Pages/MainPage/UIMainView.swift` | Add `onChange` for macro collection changes |
| `SimpleTest/Enums/AppRoute.swift` | May need new route for direct edit from section |

---

## Testing Checklist

### Navigation Flow
- [ ] Tapping Macro Split section shows dual-option menu
- [ ] "Edit Current Macro" opens editor with current macro
- [ ] "Done" button saves and returns to Main Screen
- [ ] "Manage Presets" opens the options list
- [ ] Editing from list still works (swipe to edit, save returns to list)

### UI Updates
- [ ] After editing and saving, main screen displays updated macro name
- [ ] BMR and TDEE recalculate with new macro percentages
- [ ] Macro targets (grams) update correctly
- [ ] Changes persist after app restart

### Edge Cases
- [ ] Editing the last remaining preset works
- [ ] Creating a new preset from the list works
- [ ] Canceling editor without saving doesn't modify data
- [ ] Menu appears correctly on iPhone and iPad

---

## Dependencies

- None - this is a standalone improvement
- However, depends on `ProfileViewModel` having proper `@Observable` conformance (already implemented)

---

## Notes

1. The `@Observable` macro on `ProfileViewModel` and `MacroSplitOptionsModelCollection` should automatically propagate changes, but we need to verify the main screen is observing the right values.

2. The `syncSelectedMacro()` method in `ProfileViewModel` reads from a NEW `MacroSplitOptionsModelCollection` instance rather than the environment one. This should be reviewed:
```swift
private func syncSelectedMacro() {
    if let selected = MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()).items.first(where: { $0.id == selectedMacroId }) {
        syncMacros(from: selected)
    }
}
```

This could be a bug - it's not using the environment collection, so updates to presets might not sync properly.
