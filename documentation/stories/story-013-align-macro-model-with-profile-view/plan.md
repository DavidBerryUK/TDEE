# Implementation Plan: Align Macro Model With Profile View

## Objective

Fix the Macro Options list so:
1. The currently selected macro is highlighted when navigating to the list
2. Selecting a different macro updates the profile's selection

## Current State Analysis

### Problem 1: No Pre-selection
`UIMainView` has `macroMix.selectedMacroId` tracking the current selection, but `MacroOptionsListViewPage` doesn't know about it. Its `onAppear` calls `collection.selectFirstItem()` which always selects the first item.

### Problem 2: Selection Not Synced Back
When user selects a new macro, `collection.selectItem(byId:)` updates the collection, but `macroMix.selectedMacroId` doesn't change because there's no binding between them.

### Shared State Pattern
- `MacroSplitOptionsModelCollection` is created in `SimpleTestApp` and passed via `@Environment`
- Both `UIMainView` and `MacroOptionsListViewPage` access the **same instance** via `@Environment`
- The collection is shared, but `selectedMacroId` is not passed to the navigation destination

## Solution Approach (Updated for Story 013)

### Step 1: Update ProfileViewModel to include selectedMacroId
We will add `selectedMacroId` property to `ProfileViewModel` that:
- Defaults to Balanced preset ID
- Has a property observer that syncs macro percentages from the selected preset
- Allows for automatic synchronization when selection changes

### Step 2: Pass profile's selectedMacroId to MacroOptionsListViewPage
Instead of passing `macroMix.selectedMacroId`, we'll pass `profile.selectedMacroId` via environment.

### Step 3: Update MacroOptionsListViewPage to use the passed ID
Update `onAppear` to select the passed ID instead of first item.

### Step 4: Update handleOnSelect to sync selection back to profile
Update `handleOnSelect` to properly update `ProfileViewModel.selectedMacroId`.

## Files to Modify

| File | Action |
|------|--------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | **Modify** - Add `selectedMacroId` property with property observer that syncs macro percentages |
| `Pages/MainPage/UIMainView.swift` | **Modify** - Pass `profile.selectedMacroId` via environment to `MacroOptionsListViewPage` |
| `Pages/MacroOptionsListViewPage/MacroOptionsListViewPage.swift` | **Modify** - Read binding, use in `onAppear` |
| `Pages/MacroOptionsListViewPage/SubViews/MacroOptionsListCardView.swift` | **Modify** - Update `handleOnSelect` to sync selection via profile |

## Test Checklist

- [ ] Navigating to Macro Options highlights the current profile selection (green checkmark/border)
- [ ] Selecting a different macro immediately updates the UI
- [ ] Returning to main screen shows the new selection in the macro picker
- [ ] Changing selection triggers recalculation (via `onChange(of: profile.selectedMacroId)`)
- [ ] Editing a macro preserves selection state
