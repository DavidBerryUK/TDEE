# Plan: Story 020

1. **Remove SwiftUI from shared logic (done).** Drop `import SwiftUI` from `Calculator.swift` and `AuditLogger.swift`. Confirm `ProfileViewModel` and `MacroSplitOptionsModelCollection` compile without UI types. Fix anything that depended on the theme or palette.
2. **Add the watch target.** New standalone watchOS app target `TDEEWatch` (bundle ID `DaveBerryUk.TDEE.watchkitapp`, watchOS 26.0). The shared code moved into a new `TDEEShared/` folder that both targets include, so no file membership exceptions are needed. `Models/Theme/` stays in `TDEE/` and is not in the watch target. Done.
3. **Verify SwiftData on watchOS (done: store created, presets seeded, saved age restored on relaunch).** Build `Profile`, `MacroPreset` and `SwiftDataContainer` for the watch. Seed the presets on first launch.
4. **App entry and main screen (done).** `@main` watch App, one `ProfileViewModel`, created once and passed down (see the save-loop fix: do not create it inside a view `init`). Main screen shows calories and macros. Note: standalone watch apps need `WKWatchOnly = YES`.
5. **Input screens (done; weight in kg and height in cm only, see Out of Scope).** One view per property with a wheel `Picker` and `NavigationLink`. Reuse the ranges and unit options from the phone.
6. **Presets screen (done).** Choose from the stored presets.
7. **Fixed palette (done: `WatchPalette`).** One dark palette in the watch target. No `ThemeManager`.
8. **Tests.** Run the existing tests. Add a check that a fixed input gives the same TDEE and macros on both targets.
9. **Manual check** in a watch simulator, paired with an iPhone simulator if needed.

## Risks
- Target setup in Xcode (bundle IDs, embedding the watch app) is the likeliest source of trouble.
- Shared files might still reference theme types. Step 1 finds these early.
