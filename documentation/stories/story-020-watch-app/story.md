# Story 020: Apple Watch App

**Objective:** Add a SwiftUI watchOS app that calculates TDEE and macros on the wrist, sharing the calculation and model code with the iPhone app.

## Background
The 2020 version of TDEE had a watch app built with storyboards and `WKInterfaceController`s. This story replaces that approach with a modern SwiftUI watch app (`NavigationStack`, wheel `Picker`, `@Observable`).

## Scope
- A watchOS target that matches the iOS deployment generation (watchOS 26).
- The watch app is **standalone**: it has its own storage and works without the phone.
- The watch has its **own profile**. Syncing with the phone is out of scope (see Out of Scope).

## Screens
- **Main:** calories per day and macro grams, with a row for each input (gender, age, weight, height, activity level, body fat, calorie adjustment).
- **Input screens:** one per property, each a wheel `Picker` pushed with `NavigationLink`, using the same ranges as the phone (age 16...99, etc.).
- **Macro presets:** pick from the stored presets.

## Shared code (compiled into both targets)
`Calculations/`, `Enums/` (except `Icon`, `IconStyle`, `Section`, `AppRoute`), `Utilities/`, `Config/`, `Factories/`, `Models/ProfileViewModel/`, `Models/Macros/`, `Models/SwiftData/`.

## Not shared (themes excluded)
- **Themes are not part of the watch app.** `Models/Theme/`, `Color+Theme.swift`, the theme picker and the `palette` environment value stay iPhone-only.
- The watch uses one fixed dark palette defined in the watch target.
- The watch must not read the iPhone's selected theme or appearance setting.
- Shared code must not depend on the theme types. Where it does today, that dependency moves out of the shared folders.
- Also not shared: the iPhone views (`Pages/`, `ViewSections/`, `ViewCards/`, `ViewsLayouts/`, etc.), the share card, and `ThemeManager`.

## Out of Scope
- Syncing the profile between phone and watch.
- Creating or editing custom macro presets on the watch (edit on the phone).
- Share results, About and System pages.
- Complications and widgets.

## Acceptance Criteria
- The watch app builds and runs in a watch simulator.
- A calculation on the watch gives the same TDEE and macros as the phone for the same inputs.
- Changes made on the watch are saved and restored on relaunch.
- No theme code is compiled into the watch target.
- Shared files have no UI imports beyond Foundation, Observation and SwiftData.
- The iPhone app is unchanged in look and behaviour, and the full test suite passes.
