# Story 018: Themes

**Objective:** Implement a theme system that combines a system appearance mode (Auto/Light/Dark) with a Default theme (the app's current colours), 8 Flat UI-based colour themes (Clouds, Turquoise, Emerald, Peter River, Amethyst, Sunflower, Carrot, Alizarin) and High Contrast.

**Motivation:** Users want to customise the app's appearance beyond basic light/dark mode. Different palettes suit different preferences or seasonal contexts. This is experimental, to learn which themes users value most.

**Current State** (verified against the code):
- No theme system and no dark-mode handling (`preferredColorScheme` is not used anywhere).
- Colours are a mix of system colours (`Color(.systemGroupedBackground)`) and literals (`Color.red`, `.white`, `.black`, `.gray`, etc., roughly 25 uses), plus `Constants/ColorStyles.swift` (hardcoded red/blue opacities, e.g. macro colours).
- Only the default `AccentColor` is in the asset catalog.
- A placeholder `Pages/ThemePage/ThemeView.swift` already exists. It is routed via `AppRoute.theme` in `ContentView` and linked from `UISystemPageView` ("Theme" button). There is **no** Settings view, so the theme UI replaces this placeholder.

**Expected Behaviour:**
- Appearance modes: Auto (follow system), Light, Dark.
- 10 themes (Default + 8 colour + High Contrast), each with a light and a dark palette.
- Theme and mode are chosen on the Theme page (reached from the System page).
- Selection persists across launches.
- All UI, including the share-results card, responds to changes.
- Auto mode follows the system light/dark setting live.
- Defaults: Default + Auto. An unknown or missing stored value falls back to these.

## Design Considerations

### Two independent axes
Appearance mode (Auto/Light/Dark) and colour theme are separate settings.

- `ThemeManager.appearance` maps to `.preferredColorScheme(...)` at the root: Auto → `nil`, Light → `.light`, Dark → `.dark`.
- Each `Theme` provides **both** a light and a dark `ColorPalette`. The resolved palette is chosen from the effective `ColorScheme` (read from `@Environment(\.colorScheme)`), so Auto works without extra logic.

```
ThemeManager (ObservableObject / @Observable)
├── themeID: ThemeID                      (persisted)
├── appearance: AppearanceMode            (persisted: auto | light | dark)
├── theme: Theme                          (resolved from themeID, default Default)
└── palette(for: ColorScheme) -> ColorPalette

Theme
├── id: ThemeID (String-backed enum)
├── name: String
├── light: ColorPalette
└── dark: ColorPalette

ColorPalette
├── primary / secondary
├── background / surface
├── text / textSecondary
├── border
└── macroProtein / macroCarbs / macroFat   (replaces hardcoded colours in ColorStyles)
```

`success`, `warning` and `error` are **not** themed. They stay as system semantic colours so their meaning is not lost (for example in Alizarin or Emerald).

### Appearance modes

| Mode | Description |
|------|-------------|
| Auto | Follow system light/dark appearance |
| Light | Always light |
| Dark | Always dark |

### Preset themes (Default + 8 + High Contrast)

**Default** keeps the app looking exactly as it does today. It is built from iOS system dynamic colours, so it adapts to light/dark automatically. It is exempt from the contrast criteria because Apple's own `secondaryLabel` and mint fall below them in light mode.

The other themes are based on the Flat UI palette, with one distinct hue per theme. Hex values for both light and dark versions are in [palettes.md](palettes.md), with a visual preview in [palette-preview.html](palette-preview.html).

| Theme | Hue | Secondary |
|-------|-----|-----------|
| Default | The app's current iOS system colours, blue accent | System red |
| Clouds | Greys, wet-asphalt accent | Concrete |
| Turquoise | Turquoise | Wet asphalt |
| Emerald | Green | Green sea |
| Peter River | Sky blue | Turquoise |
| Amethyst | Purple | Pink |
| Sunflower | Yellow | Carrot |
| Carrot | Orange | Pumpkin |
| Alizarin | Red | Pomegranate |
| High Contrast | Black/white, single blue accent | — |

- Backgrounds are lightly tinted with the theme hue.
- In light mode, accents are darkened until they meet contrast requirements. Dark mode uses near-original Flat UI colours.
- Macro colours are shared by all themes (protein pink, carbs blue, fat yellow) and adjusted per mode. This trio passes deuteranopia and protanopia separation checks.

Sunflower light intentionally uses a darker, text-safe gold as its primary. No separate fill token is needed.

### Persistence
- Theme and appearance are **device preferences**, not profile data. Store them in `UserDefaults` (via `@AppStorage` or inside `ThemeManager`), **not** in SwiftData or `ProfileViewModel`.
- Store raw string values. On load, an unrecognised value falls back to Default / Auto.
- No iCloud sync.

### Accessibility
- Body text vs background must meet WCAG AA (4.5:1), and large text and UI components 3:1, in **every** theme in **both** schemes. Verify with a contrast check (documented in the PR).
- High Contrast should aim for AAA (7:1).
- Information must not rely on colour alone (macro colours also have labels).
- Dynamic Type is unaffected. Themes change colour only, not fonts or spacing.

### Theme page UI
- Appearance: segmented control (Auto / Light / Dark).
- Themes: grid of cards, each with a swatch strip and name, and a checkmark on the selected one.
- Selecting a card applies it immediately (live preview, no confirm step), and the page itself re-themes.

### Access
- **System page → Theme** (existing route).
- **Main screen shortcut:** a `paintpalette` toolbar button at the top right, next to the Share menu, pushes the same `AppRoute.theme`. Its accessibility label is "Change theme".

## Phases

### Phase 1: Infrastructure
1. `AppearanceMode`, `Theme`, `ColorPalette`, `ThemeManager` with UserDefaults persistence.
2. `Color+Theme` accessors (theme colours via the environment).
3. Inject `ThemeManager` at the root in `TDEEApp` and apply `.preferredColorScheme`.
4. Ship Default only, with light and dark palettes, plus the appearance selector in `ThemeView`.
5. Migrate hardcoded colours in views and `ColorStyles` to palette tokens.

### Phase 2: Theme selection and remaining palettes
1. Theme card grid in `ThemeView`.
2. Add the remaining 9 themes from `palettes.md`.
3. Re-run contrast verification for all palettes (Default is exempt).

### Phase 3: Customisation (future, out of scope)
Custom theme editor, per-entry colour customisation, saving, and export/import.

## Files

### New (Phase 1–2)
Paths follow the existing project layout under `TDEE/`.

| File | Purpose |
|------|---------|
| `Models/Theme/Theme.swift` | `Theme` and `ColorPalette` |
| `Models/Theme/ThemeManager.swift` | State, resolution and persistence |
| `Models/Theme/AppearanceMode.swift` | Auto/Light/Dark enum |
| `Models/Theme/DefaultThemes.swift` | The 10 theme definitions |
| `Pages/ThemePage/ThemeCardView.swift` | Swatch card |
| `Constants/Color+Theme.swift` | Theme-aware colour accessors |

### Modified
| File | Change |
|------|--------|
| `Pages/ThemePage/ThemeView.swift` | Replace placeholder with appearance picker and theme grid |
| `ContentView.swift` | Add the main-screen `paintpalette` toolbar shortcut to the Theme page |
| `TDEEApp.swift` | Create and inject `ThemeManager`, apply `.preferredColorScheme` |
| `Constants/ColorStyles.swift` | Source macro/fill colours from the palette |
| Views using literal colours (`Pages/*`, `ViewSections/*`, `ViewCards/*`, `ViewsLayouts/*`, `Pages/ShareCard/ShareCardView.swift`) | Use palette tokens |

`ProfileViewModel` and SwiftData models are **not** changed.

## Acceptance Criteria
- [ ] Auto/Light/Dark switches the whole app immediately. Auto tracks the system live.
- [ ] All 10 themes render correctly in light and dark on every screen (previews or screenshots for each).
- [ ] Theme and mode persist across relaunch.
- [ ] A missing or invalid stored value results in Default + Auto without a crash.
- [ ] No literal `Color.*` values remain in views, other than `.clear` and the semantic success/warning/error colours.
- [ ] The palette button on the main screen opens the Theme page, and back returns to the main screen.
- [ ] Contrast requirements met (see Accessibility) by every theme except Default.
- [ ] Default looks identical to the app before this story in light mode, and uses correct system colours in dark mode.
- [ ] Share-results card (story 015) renders legibly in every theme, and the shared image is still correct.

## Testing
- Unit: `ThemeManager` persistence round-trip, fallback for unknown IDs, palette resolution by scheme.
- Unit: every theme has both palettes, and each meets the contrast thresholds (computed from the hex values).
- Manual: switch themes and modes on each screen, and with the system setting changed while in Auto.

## Decisions

| Question | Answer |
|----------|--------|
| User-defined themes? | Not in v1 (Phase 3) |
| Themes affect fonts or spacing? | No, colour only |
| iCloud sync? | No |
| Number of themes in v1? | Default + 8 Flat UI colour themes + High Contrast |
| Auto mode? | Yes |
| Where does persistence live? | UserDefaults, not SwiftData |

## Dependencies
None. This is a standalone feature, though the share card (story 015) should be re-checked.

## References
- https://www.figma.com/resource-library/color-combinations/
- https://color.adobe.com/explore?q=Luxury
