# Story 001: Simulator/Device Configuration

## Objective

Add a configuration system that provides different default values based on whether the app is running on a simulator or a physical device.

## Motivation

When developing iOS apps, it's common to want different default values in the simulator (e.g., preset test data, faster iteration defaults) versus on a physical device (e.g., empty fields requiring user input, production-ready defaults).

## Acceptance Criteria

1. The app reads configuration values at launch
2. Simulator instances receive different defaults than device instances for all configured fields
3. Configuration is type-safe and discoverable
4. New defaults can be added without modifying core calculation logic
5. Defaults apply to: Gender, Age, Height, Weight, Activity Level, Body Fat Percentage

## Open Questions

- **Configuration format**: Should we use a plist, JSON, or Swift struct with compiler directives?
  - Options discussed:
    - `.plist` file (human-readable, Xcode-integrated)
    - JSON file (lightweight, easy to edit)
    - Swift struct with `#if targetEnvironment(simulator)` (compile-time optimized)

- **Configuration location**: Should the config be bundled with the app, or loadable from a remote source?

- **Gender default**: Since Gender is an enum (`.male`, `.female`), what should the default be for each environment?

## Configuration Keys

| Key | Simulator Default | Device Default |
|-----|------------------|----------------|
| Gender | `.male` | `.male` |
| Age | 25 | 16 |
| Height | 175.0 cm | 0.0 cm |
| Weight | 70.0 kg | 0.0 kg |
| Activity Level | `.moderateExercise` | `.sedentary` |
| Body Fat Percentage | 15.0% | 0.0% |

## Decisions

TBD - to be completed during planning phase.

## Implementation Notes

The configuration should be accessed through a single entry point (e.g., `AppConfig` struct) to keep the separation clean and testable.
