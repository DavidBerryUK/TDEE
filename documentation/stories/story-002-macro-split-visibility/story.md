# Story 002: Macro Split Visibility

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
