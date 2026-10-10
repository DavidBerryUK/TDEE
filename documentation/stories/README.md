# Stories

This directory contains user stories for the SimpleTest iOS project.

## Story Status

| # | Title | Status |
|---|-------|--------|
| 001 | Simulator/Device Configuration | In Progress |

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
