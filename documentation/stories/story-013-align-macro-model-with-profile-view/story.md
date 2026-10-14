# Story 013: Align Macro Model With Profile View

**Objective:** Store the selected macro option's ID in `ProfileViewModel` so the macro selection is tied to the profile data rather than being a separate, temporary state.

## Motivation

Currently, the macro selection is stored in `MacroSplitViewModel`, which is a separate view model from `ProfileViewModel`. This creates a disconnect:
- `ProfileViewModel` stores macro percentages as raw integers (protein, carbs, fats)
- `MacroSplitViewModel` holds the selected macro preset ID
- The `syncSelectedMacro()` method in `UIMainView` copies values from the selected preset into the profile

This separation is fragile because:
1. If the profile is saved/restored separately, the macro selection is lost
2. It's unclear which source of truth should be used for macro selection
3. The sync happens only on recalculation, not on selection

## Current State

### ProfileViewModel
- Stores macro targets as raw integers: `protein: Int`, `carbs: Int`, `fats: Int`
- No reference to the selected macro preset (this is being fixed)

### MacroSplitOptionsModelCollection
- Predefined list of macro presets (Balanced, Diet, Body Builder, Ketogenic, Rest, Training, Zone)
- Each preset has: `id` (UUID), `name`, `protein`, `carbs`, `fats`, `ordinal`
- Available as an `@Environment` value throughout the app

### MacroSplitViewModel
- Contains only `selectedMacroId: UUID`
- Used by the picker UI to display the current selection

### UIMainView.syncSelectedMacro()
- Manually syncs the selected preset's values into `ProfileViewModel`
- Called before recalculation

## Expected State

### ProfileViewModel
- Add `selectedMacroId: UUID` property (non-optional, defaults to Balanced preset ID)
- Macro percentages (`protein`, `carbs`, `fats`) remain as **stored values** that can be edited via UI
- When `selectedMacroId` changes, automatically sync the macro percentages from the preset
- When user edits macro values via UI, the percentages change but `selectedMacroId` stays the same (tracks "original" preset)

## Implementation Notes

### Files to Consider Modifying

| File | Change |
|------|--------|
| `Models/ProfileViewModel/ProfileViewModel.swift` | Add `selectedMacroId` property with property observer that syncs macro percentages |
| `Models/ProfileViewModel/ProfileViewModelMacro.swift` | Update `syncMacros(from:)` to handle nil/empty case; consider renaming/refactoring |
| `ViewsValueEditors/UIWheelPickerMacroMixView.swift` | Update to bind directly to `ProfileViewModel.selectedMacroId` |
| `ViewsSectionSummaryValues/UISectionSummaryValueMacroMix.swift` | Update to use profile's selected macro for display |
| `Pages/MainPage/UIMainView.swift` | Remove `macroMix` state; use `profile.selectedMacroId` directly |

### Design Decisions Needed

1. **Should `selectedMacroId` be optional?**
   - No - always has a value, defaults to 'Balanced' preset
   
2. **How do macro values relate to selectedMacroId?**
   - Values are stored and editable via UI
   - `selectedMacroId` tracks the "original" preset
   - Editing values doesn't change `selectedMacroId`
   - Changing `selectedMacroId` resets values from the new preset
   
3. **How to handle custom macros?**
   - User-created macros stored in `MacroSplitOptionsModelCollection`
   - `selectedMacroId` can reference any option in the collection

## Open Questions

1. Should changing profile values (age, weight, etc.) automatically reset or recalculate macros?
2. Should there be a way to "reset to preset" values (revert edited values back to the selected preset's defaults)?

## Decisions

### Approach
- Add `selectedMacroId: UUID` to `ProfileViewModel` (defaults to Balanced preset)
- Macro percentages (`protein`, `carbs`, `fats`) remain stored values
- When `selectedMacroId` changes, copy values from the selected preset
- When user edits via UI, only the percentage values change, not `selectedMacroId`

### Rationale
1. **Single source of truth**: The profile owns the macro selection (`selectedMacroId`) AND the current values
2. **Editable presets**: Users can customize a preset and the selection stays tied to the original
3. **Persistence-friendly**: Macro selection and values are part of profile data
4. **Backward compatible**: Existing UI components can continue working with stored values

## Status Update (Post-Implementation)

### Issue Fixed:
The implementation now correctly aligns macro model with profile view by:

1. **Adding `selectedMacroId` to ProfileViewModel** - This property stores the UUID of the currently selected macro option
2. **Property observer for automatic sync** - When `selectedMacroId` changes, the macro percentages (`protein`, `carbs`, `fats`) are automatically synced from the selected preset
3. **Persistent selection** - The macro selection is now tied to profile data, so it persists when the profile is saved/restored

### Benefits:
- Macro selection is now part of profile data, not separate state
- Selection persists across profile save/restore operations
- UI components can reference the same source of truth for both selection and values
- The change maintains backward compatibility with existing UI components
