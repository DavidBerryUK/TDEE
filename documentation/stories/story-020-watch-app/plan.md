# Plan: Story 020

1. **Remove SwiftUI from shared logic.** Drop `import SwiftUI` from `Calculator.swift` and `AuditLogger.swift`. Confirm `ProfileViewModel` and `MacroSplitOptionsModelCollection` compile without UI types. Fix anything that depended on the theme or palette.
2. **Add the watch target.** New watchOS app target, standalone, using folder-based groups. Include only the shared folders listed in the story. Keep `Models/Theme/` out of it.
3. **Verify SwiftData on watchOS.** Build `Profile`, `MacroPreset` and `SwiftDataContainer` for the watch. Seed the presets on first launch.
4. **App entry and main screen.** `@main` watch App, one `ProfileViewModel`, created once and passed down (see the save-loop fix: do not create it inside a view `init`). Main list shows calories and macros.
5. **Input screens.** One view per property with a wheel `Picker` and `NavigationLink`. Reuse the ranges and unit options from the phone.
6. **Presets screen.** Choose from the stored presets.
7. **Fixed palette.** One dark palette in the watch target. No `ThemeManager`.
8. **Tests.** Run the existing tests. Add a check that a fixed input gives the same TDEE and macros on both targets.
9. **Manual check** in a watch simulator, paired with an iPhone simulator if needed.

## Risks
- Target setup in Xcode (bundle IDs, embedding the watch app) is the likeliest source of trouble.
- Shared files might still reference theme types. Step 1 finds these early.
