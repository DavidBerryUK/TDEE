# Stories

This directory contains user stories for the SimpleTest iOS project.

## Story Status

| # | Title | Status |
|---|-------|--------|
| 001 | Simulator/Device Configuration | Done |
| 002 | Macro Split Visibility | In Progress |

---

## Story 001: Simulator/Device Configuration

**Objective:** Add a configuration system that provides different default values based on whether the app is running on a simulator or a physical device.

**Motivation:** When developing iOS apps, it's common to want different default values in the simulator (e.g., preset test data) versus on a physical device (e.g., empty fields requiring user input).

**Open Questions:**
- Should the configuration be loadable at runtime, or compile-time via build settings?
- Should the config be bundled with the app, or loadable from a remote source?

**Configuration Keys:**
| Key | Simulator Default | Device Default |
|-----|------------------|----------------|
| Gender | `.male` | `.male` |
| Age | 25 | 16 |
| Height | 175.0 cm | 0.0 cm |
| Weight | 70.0 kg | 0.0 kg |
| Activity Level | `.moderateExercise` | `.sedentary` |
| Body Fat Percentage | 15.0% | 0.0% |

**Decisions:**
- Configuration format: Swift struct with `#if targetEnvironment(simulator)` compiler directive
- Storage: Hardcoded values (no external files needed initially)

**Depends on:** None

---

## Story 002: Macro Split Visibility

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
