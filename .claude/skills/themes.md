# themes

Reference for the TDEE theme system — how to read, modify, or add a theme without breaking the picker/section views.

## When to use

Use this skill before touching any of:
- `TDEE/Models/Theme/**` (`Theme.swift`, `DefaultThemes.swift`, `PickerDressing.swift`,
  `SectionDressing.swift`, `GlowDressing.swift`, `ThemeTypography.swift`, `ThemeManager.swift`,
  `AppearanceMode.swift`)
- `TDEE/Constants/Color+Theme.swift` (env entries, `ThemedRoot`, `PaletteResolver`, the view modifiers)
- `TDEE/Pages/ThemePage/**` (the picker UI), `TDEE/ViewsIcon/UIIcon.swift`,
  `TDEE/ViewsLayouts/UILayoutSectionView.swift`, `TDEE/Pages/MainPage/MainSectionProfileInput.swift`
- any `UIWheel*Plain` / `UIWheel*Themed` picker (frozen — read the dressing instead of editing them)
- adding, changing, or tuning a theme or one of its extended features

## Read first

The full architecture is in **`documentation/theme-architecture.md`** — start there. It covers:
- the **opt-in / nil-default / views-frozen** model (the one idea to internalise)
- the type graph and file map
- the colour roles and the seven picker fields
- resolution flow (`ThemedRoot` → `PaletteResolver` → `resolved(for:)`)
- **the per-theme feature matrix** (which themes use `toolbar` / `iconColors` / `expandedContentBackground`
  / `pickerDressing` / `sectionDressing` / `glow` / `cardFrame` / `typeface`)
- recipes: add a plain theme, add a dressed theme, change colours, tune a picker, add an icon
- the test invariants (`ThemeTests`, `PickerDressingTests`) and the **iPhone 17 Pro Max / iOS 27.0** target
- the watch is `WatchPalette` (fixed, iPhone-only — do not wire it to the theme system)

## Rules of thumb

- **Appearance changes go in the *model* (a palette/dressing), never the frozen picker/section views.**
- **Every extended field is `nil`-default** — adding one is safe for existing themes.
- **Tune pickers via a `PickerDressing`** (`.orange` / `.panel(…)`), not the seven loose fields or the views.
- **Keep `ThemeID` and `DefaultThemes.all` in sync** (Default first); bump `testAllThemes` when adding a theme.
- **Run a contrast pass** (`testContrast`) on any colour change; `Default` is exempt by design.

Color hex source of truth: `documentation/stories/story-018-themes/palettes.md`.
Build/test: see `.claude/skills/compile.md`.
