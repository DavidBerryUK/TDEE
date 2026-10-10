# Implementation Plan: Story 002 - Macro Split Visibility

## Files to Review

1. Find and review the Macro Split view component
   - Search for `MacroSplit` in the codebase
   - Identify the view that expands when tapped

2. Review the parent view that contains the Macro Split
   - Determine if it's wrapped in a `ScrollView`
   - Check the layout structure

## Implementation Steps

1. **Identify the container layout**
   - If using `List`, consider switching to `ScrollView` with `LazyVStack`
   - If using `VStack`, wrap in `ScrollView`

2. **Adjust content padding/margins**
   - Ensure there's sufficient bottom padding so the expanded panel is fully visible
   - Use `.padding(.bottom)` if needed

3. **Test on different screen sizes**
   - Test in simulator with various iPhone sizes
   - Verify the macro panel scrolls into view when expanded

## Expected Files to Modify

- Search results will reveal the exact files to modify

## Tests to Verify

- Macro Split expands when tapped
- Macro readout (protein, carbs, fat) is visible after expansion
- User can scroll to see the full expanded panel if needed
