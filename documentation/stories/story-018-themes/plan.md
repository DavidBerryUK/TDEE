# Plan: Story 018 - Themes

Branch: `features/story-018-themes`

Palettes: [palettes.md](palettes.md) (final, 10 themes × light/dark). Preview: [palette-preview.html](palette-preview.html).

## Findings from the code
- `TDEEApp` is a bare `WindowGroup { ContentView() }`, with no colour scheme handling.
- Colours live in three places:
  - `Constants/UIStyle.swift`: macro colours (protein red 0.85, carbs blue, **fats mint**), edit/read-only/error font colours.
  - `Constants/ColorStyles.swift`: red/blue opacity fills, used in `MacroEditViewPage`.
  - Literals in views. The heaviest use is `ViewsIcon/UIIcon.swift` (13: per-section icon hues), then `MacroEditViewPage` (7), `MacroOptionsListCardView` (5), `UICardNumericResult` (4), `UIExpanderView` (3) and `ShareCardView` (3), plus about 10 single uses.
- `Pages/ShareCard/ShareCardView.swift` renders via `ImageRenderer` with a hard `Color.white` background. Rendered content does not inherit the app environment, so the palette must be passed in explicitly.
- `Pages/ThemePage/ThemeView.swift` is a placeholder already routed (`AppRoute.theme`) from `UISystemPageView`.
- `Color.readableTextColor()` exists in `ColorExtensions.swift` and can be reused for the swatch labels.

## Decisions
- **Palette source of truth:** `DefaultThemes.swift`, with hex values copied from `palettes.md`. A `Color(hex:)` initialiser is added if not already present.
- **Resolution:** `ThemeManager` is `@Observable`, injected with `.environment(themeManager)` at the root. Views read `@Environment(\.palette)`. A custom `EnvironmentKey` is set at the root from `themeManager.theme` + `@Environment(\.colorScheme)`, so the light/dark switch is automatic, including Auto.
- **Persistence:** `UserDefaults` keys `theme.id` and `theme.appearance` (raw strings). An unknown value falls back to `.standard` / `.auto`.
- **Semantic colours:** error and validation red stays `Color.red` (system), not themed, as the story specifies.
- **Section icons** (`UIIcon`): these are content colours, not theme chrome, so they keep their hues. The macro icons (protein/carbs/fats) switch to the palette macro tokens so they match the bars. The other icons are checked for contrast on dark surfaces and adjusted if needed.
- **Share card:** always renders with the **light** palette of the current theme (a predictable shared image, and readable in messaging apps). It is passed as a parameter, not taken from the environment.
- **Theme count:** 10: Default + 8 Flat UI colour themes + High Contrast.
- **Default theme** = the current app colours, built from **system dynamic colours** (`Color(.systemGroupedBackground)`, `Color(.secondarySystemGroupedBackground)`, `.primary`, `.secondary`, `Color(.separator)`, `.blue`, `.red`, `.mint`), not hex values, so it matches today's app exactly and follows iOS. Macro protein stays `.red.opacity(0.85)`. It is the default and the fallback. Its enum case is `standard` (`default` is a Swift keyword), shown to users as "Default". The existing `Color.white` card backgrounds become `palette.surface`, which also fixes them in dark mode.

## Phase 1: Model and persistence (test-first)
New files in `TDEE/Models/Theme/`:
1. `AppearanceMode.swift`: `enum AppearanceMode: String, CaseIterable { auto, light, dark }` with `colorScheme: ColorScheme?`.
2. `Theme.swift`: `struct ColorPalette` (10 tokens from `palettes.md`) and `struct Theme { id: ThemeID, name, description, light, dark }`, plus `func palette(for: ColorScheme)`.
3. `DefaultThemes.swift`: `enum ThemeID: String, CaseIterable` (standard, clouds, turquoise, emerald, peterRiver, amethyst, sunflower, carrot, alizarin, highContrast) and `static let all: [Theme]`.
4. `ThemeManager.swift`: `@Observable final class`, with `themeID` and `appearance` persisted in `didSet`, `init(defaults: UserDefaults = .standard)` and a computed `theme`.

Tests in `TDEETests/ThemeTests.swift`:
- Defaults are Default (`.standard`) + Auto when no stored values exist.
- Persistence round trip through a suite-named `UserDefaults`.
- An invalid stored ID or appearance falls back to the defaults.
- All 10 themes exist, with unique IDs.
- **Contrast test:** for every theme and mode, text and primary are ≥ 4.5 (7.0 for High Contrast), and secondary and macros are ≥ 3.0 vs surface. **Default is skipped**, because it uses system colours that are deliberately unchanged. This is a port of the WCAG luminance formula and guards against later edits to the palettes.
- `AppearanceMode.colorScheme` mapping.

## Phase 2: App wiring
1. `Constants/Color+Theme.swift`: `Color(hex:)`, `PaletteKey: EnvironmentKey` (default = Default light) and `EnvironmentValues.palette`.
2. `TDEEApp`: `@State private var themeManager = ThemeManager()`. The root gets `.environment(themeManager)` and `.preferredColorScheme(themeManager.appearance.colorScheme)`.
3. A small root wrapper view reads `colorScheme` and sets `.environment(\.palette, themeManager.theme.palette(for: colorScheme))`. Also set `.tint(palette.primary)` so system controls pick up the accent.
4. Smoke check: switching the simulator appearance in Auto changes the palette.

## Phase 3: Theme page UI
Replace the `ThemeView` placeholder:
- A "Appearance" section: segmented `Picker` for Auto / Light / Dark.
- A "Theme" section: `LazyVGrid` of `ThemeCardView` (new, `Pages/ThemePage/`). Each card has a swatch strip (primary, secondary, background, surface, macro colours), the name and a checkmark when selected. The swatches show the palette for the current scheme.
- Tapping applies immediately. Add accessibility labels ("Turquoise theme, selected").
- Previews: the page in light and dark.

## Phase 4: Migrate colours
Work file by file and build after each group:
1. `UIStyle.Colors.macro*` reads from the palette. Static constants can't see the environment, so change them to functions that take a `ColorPalette`, or have the call sites read `palette.macroProtein` directly. Prefer direct reads, and remove the statics when they're unused. Fats changes from mint to the palette yellow.
2. `ColorStyles` fills: map to `palette.macroProtein.opacity(...)` / `palette.primary.opacity(...)` at the call sites in `MacroEditViewPage`, then delete `ColorStyles` if it's empty (keep `primaryTextDisabled` as a system colour).
3. Backgrounds: `Color(.systemBackground)` / `.systemGroupedBackground` → `palette.background`. Card surfaces → `palette.surface`. Separators/borders → `palette.border`.
4. Text: `.primary` / `.gray` read-only text → `palette.text` / `palette.textSecondary`. The "edit" font colour (currently red when expanded) → `palette.primary`. Error stays red.
5. `UIIcon`: macro icons use palette macro tokens. Other icons keep their hue (check them on dark surfaces).
6. `MacroInformationBarView`: segment colours come from the palette. Keep `readableTextColor()` for the labels. The empty track `systemGray5` → `palette.border`.
7. `ShareCardView`: add a `palette: ColorPalette` parameter. The caller passes `theme.light`. Replace `Color.white` and the macro literals.
8. Final grep: there are no `Color.red/blue/green/...` literals left in views apart from the error states and `.clear`. Record any intentional exceptions in this file.

## Phase 5: Verification
- Full test run: `xcodebuild -project TDEE.xcodeproj -scheme TDEE -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test`.
- Manual check on the simulator, for each theme in light and dark: main page (all sections expanded and collapsed), macro list, macro edit, About, System, Theme page and the share sheet image. Also check force-quit and relaunch (persistence), and an appearance change made in system settings while in Auto.
- Check with Settings → Accessibility → Larger Text and Increase Contrast that nothing breaks.
- Record the results in `story.md`.

## Phase 6: Wrap-up
- Mark story 018 Done in `documentation/stories/README.md`.
- Merge into `develop` with `--no-ff` (see the implement-story skill).

## Risks
- **Environment not reaching sheets/navigation destinations:** set the palette at the root above the `NavigationStack`. Sheets inherit custom environment values in current SwiftUI, but verify this for the share sheet and the macro edit sheet.
- **ImageRenderer ignores the environment:** handled by the explicit palette parameter.
- **Static `UIStyle` colours used widely:** migrating call sites is the bulk of the effort. Do it per file with builds in between.
- **Palette drift:** the contrast unit test stops a later edit from breaking accessibility.
- **Tinted backgrounds vs system list styling:** `List`/`Form` need `.scrollContentBackground(.hidden)` plus a palette background to show the theme tint.
