# Implementation Summary for Story 013: Align Macro Model With Profile View

## Current State Analysis

The current implementation has several issues that prevent proper alignment of macro model with profile view:

### Issues Identified:

1. **Missing `selectedMacroId` in ProfileViewModel**: The `ProfileViewModel` lacks the `selectedMacroId` property as required by the story documentation.

2. **Separate State Management**: Macro selection is tracked in `MacroSplitViewModel` separately from `ProfileViewModel`, creating a disconnect where selections aren't tied to profile data.

3. **No Pre-selection in Macro Options List**: When navigating to the macro options list, the currently selected macro is not highlighted - it always selects the first item.

4. **Selection Not Synced Back to Profile**: When user selects a different macro in the options list, the change only updates `MacroSplitViewModel` and isn't persisted in `ProfileViewModel`.

## Required Changes

### 1. Add `selectedMacroId` to ProfileViewModel
- Add `selectedMacroId: UUID` property (non-optional, defaults to Balanced preset ID)
- Add property observer that automatically syncs macro percentages from the selected preset
- Keep existing macro percentages (`protein`, `carbs`, `fats`) as stored values that can be edited via UI

### 2. Update UIMainView Navigation
- Pass `$profile.selectedMacroId` to `MacroOptionsListViewPage` via environment
- Remove dependency on separate `macroMix` for tracking selection

### 3. Update MacroOptionsListViewPage
- Read the passed binding for selected macro ID
- Use this to pre-select the current selection instead of always selecting first item
- Update `onAppear` logic to respect current selection

### 4. Update MacroOptionsListCardView
- Handle selection and sync back to profile using the environment binding
- Ensure changes are propagated to `ProfileViewModel.selectedMacroId`

## Implementation Approach

The implementation should:
1. Make `ProfileViewModel` the single source of truth for macro selection
2. Maintain backward compatibility with existing UI components that work with stored values
3. Ensure that when users edit macro values via UI, the percentages change but `selectedMacroId` stays tied to the original preset
4. When `selectedMacroId` changes, automatically sync the macro percentages from the new preset