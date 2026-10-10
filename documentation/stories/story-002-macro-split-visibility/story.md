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
- Should the expansion be animated? - **No** - the panel is already expanded, just not fully visible
- Should scrolling be enabled within the expanded view? - **No** - the screen itself needs to be scrollable so the expanded panel is visible within the viewport

**Implementation Notes:**
- Review `MacroSplitView` or similar macro-related view
- Ensure the container view is a `ScrollView` (not `List` or non-scrolling stack)
- Adjust layout so the expanded macro panel appears within the visible viewport
- Ensure layout adapts to different screen sizes

**Depends on:** None
