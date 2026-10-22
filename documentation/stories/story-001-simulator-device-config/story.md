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

All resolved (2026-10-10):

- **Configuration format**: a Swift struct selected at compile time with `#if targetEnvironment(simulator)` (see Decisions). `.plist` and JSON were rejected — they add bundle files and parsing for no benefit.
- **Configuration location**: hardcoded in source, not bundled as data and not loadable from a remote source — simplest and type-safe. A remote source would be a future concern, out of scope here.
- **Gender default**: `.male` in both environments (see Configuration Keys).

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

- **Format**: a Swift struct selected at compile time with `#if targetEnvironment(simulator)` — `ConfigLoader.loadProfileDefaults()` returns `ProfileDefaults.simulator()` or `.device()`, with no external files. Chosen for type safety and zero parsing/loading overhead; `.plist` and JSON were rejected for adding bundle files and parsing for no benefit.
- **Location**: hardcoded in source (`TDEEShared/Config/`); not bundled as data, not remotely loadable.
- **Entry point**: `AppConfig.shared.profileDefaults`, consumed by `ProfileViewModel` for its field defaults, keeping the defaults out of the calculation logic.
- **Gender default**: `.male` in both environments.

## Implementation Notes

The configuration is accessed through a single entry point, `AppConfig`, to keep the separation clean and testable. `ConfigLoader` picks the defaults at compile time and `ProfileViewModel` reads them from `AppConfig.shared.profileDefaults`.

## Status

Done (2026-10-10). `AppConfig`, `ConfigLoader` and `ProfileDefaults` live in `TDEEShared/Config/` and `ProfileViewModel` reads its field defaults from `AppConfig.shared`. Merged into `develop`.
