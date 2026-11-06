# Theme Architecture

> A working reference for **adding** and **modifying** themes in TDEE, and for understanding which
> themes use which of the *extended* (opt-in) features. Read this before touching
> `TDEE/Models/Theme/`, `DefaultThemes.swift`, or any `UIWheel*` / section view.
>
> Source of truth for colours: [`story-018-themes/palettes.md`](stories/story-018-themes/palettes.md)
> (hex tables + contrast summary). Generalisation history:
> [story-024-picker-dressing](stories/story-024-picker-dressing/story.md) and
> [story-018-themes](stories/story-018-themes/story.md).

---

## 1. The one idea: opt-in dressing, nil-default, views frozen

Every appearance knob on a theme is **optional and `nil` by default**. A theme that leaves a field
`nil` renders **byte-for-byte unchanged** — exactly the original look. Richer themes *opt in* to a
feature by setting that field.

Two consequences make the codebase tractable:

1. **The dressing lives in the model layer, not the views.** A theme's picker / section / glow /
   typography appearance is a small *value type* (`PickerDressing`, `SectionDressing`, `GlowDressing`,
   `ThemeTypography`, `CardFrame`) that a `ColorPalette` *adopts*. The init of `ColorPalette` expands
   the dressing into the concrete fields the views already read. **The picker/section/card views are
   frozen** — they read the fields by name and never learn about the dressing types. This is the
   project's picker-freeze discipline (see the `UI AGENT WARNING` headers on the `UIWheel*` files,
   memory `[[picker-views-frozen]]`).
2. **Adding a feature never touches existing themes.** Because the field is `nil`-default, every
   existing theme keeps its current rendering the moment you add a new optional field. A new feature is
   safe to land without a per-theme migration.

**Rule of thumb:** to change *how a theme looks*, change the model (a palette or a dressing in
`DefaultThemes.swift` / the dressing types). Do **not** edit the frozen views.

---

## 2. Type graph (and where each piece lives)

```
ThemeManager                     @Observable, persisted to UserDefaults. themeID + appearance.
  └─ theme: Theme = DefaultThemes.theme(for: themeID)

Theme (Theme.swift)              id · name · description · light: ColorPalette · dark: ColorPalette
                                 + optional colorScheme? (pin) and typeface?: ThemeTypography
  └─ palette(for:) -> ColorPalette   (light/dark by scheme)

ColorPalette (Theme.swift)       the bag of colour ROLES every view draws from. Built ONLY in
                                 DefaultThemes.swift (and, separately, the watch's WatchPalette).
  └─ resolved(for: Icon) -> ColorPalette   per-section substitution (see §6)

Dressings (each its own file in TDEE/Models/Theme/):
  PickerDressing   the wheel picker's 7 fields, bundled → adopted via ColorPalette(pickerDressing:)
  SectionDressing  per-section accents [Icon: SectionAccent] + mode/intensity/layout
  GlowDressing     neon bloom (outline + core + halo + tube core + heading glow)
  ThemeTypography  a custom font family (Dynamic-Type-preserving)
  CardFrame        an outline drawn around every card

Consumption (TDEE/Constants/Color+Theme.swift):
  ThemedRoot -> PaletteResolver injects  .environment(\.palette)  +  .environment(\.themeTypography)
                                 + .tint(palette.primary)
  View modifiers: .themedGroupedList · .themedToolbarBackground · .pickerPanel · .segmentDressing
                  · .sectionDressed(for:) · .neonCard / .neonGlowBloom / .neonHeading / .neonTube
  Views read  @Environment(\.palette)  /  @Environment(\.themeTypography)
```

### File map

| File | Role |
|---|---|
| `TDEE/Models/Theme/Theme.swift` | `ColorPalette` (all role fields + `resolved(for:)`), `Theme`, `Color(hex:)` + `legibleText`/`lightTint` helpers |
| `TDEE/Models/Theme/DefaultThemes.swift` | `ThemeID`, `DefaultThemes.all`, every theme's palettes. **The only place a `ColorPalette` is built.** |
| `TDEE/Models/Theme/PickerDressing.swift` | the wheel-picker dressing + `.plain` / `.orange` / `.panel(…)` |
| `TDEE/Models/Theme/SectionDressing.swift` | `SectionAccent`, `SectionDressing` + `.pride` / `.neon` / `.warmGradient`, `CardFrame` |
| `TDEE/Models/Theme/GlowDressing.swift` | `GlowLayer`, `TubeCore`, `GlowDressing` + `.full` / `.fullLight` / `.fullLightTube` |
| `TDEE/Models/Theme/ThemeTypography.swift` | font family resolution + `.system` / `.sourceSans3` / `.tiltNeon` + bundled-font registration |
| `TDEE/Models/Theme/ThemeManager.swift` | selection + appearance, `UserDefaults` persistence |
| `TDEE/Models/Theme/AppearanceMode.swift` | `auto` / `light` / `dark` → `ColorScheme?` |
| `TDEE/Constants/Color+Theme.swift` | env entries, `ThemedRoot`, `PaletteResolver`, all the `View` modifiers + their modifiers |
| `TDEE/Enums/Icon.swift` · `IconStyle.swift` | the 11 icons; the 6 icon render styles |
| `TDEE/Pages/ThemePage/ThemeView.swift` · `ThemeCardView.swift` | the picker UI (Appearance header + theme card grid) |
| `TDEE/ViewsIcon/UIIcon.swift` | icon colour precedence |
| `TDEE/ViewsLayouts/UILayoutSectionView.swift` | the section header (icon + title + chevron + expand/collapse) |
| `TDEE/Pages/MainPage/MainSectionProfileInput.swift` | the input-card layout (undressed / `.separate` / `.joined`) |
| `TDEEWatch/enums/WatchPalette.swift` | the watch's fixed palette (themes are iPhone-only) |
| `TDEETests/ThemeTests.swift` · `PickerDressingTests.swift` | the invariants (see §10) |

---

## 3. The colour roles (`ColorPalette`)

Every view draws from these. The first ten are the base set; the rest are **optional extended features**
(`nil` = original look). Constructed via `ColorPalette(...)` — `editText`/`highlight`/`selection`
default to `primary`, and every extended field defaults to `nil`.

### Base roles

| Field | Meaning |
|---|---|
| `primary` | accent: CTA text, links, selection, tint. Also the default for `editText`/`highlight`/`selection`. |
| `secondary` | secondary accent |
| `background` | the page (behind grouped lists/cards) |
| `surface` | card / row / section fill |
| `text` | body text |
| `textSecondary` | captions, subheadings, chevrons |
| `border` | dividers, card outlines |
| `macroProtein` / `macroCarbs` / `macroFat` | the macro tile/bar colours |

### Optional extended features (all `nil`-default)

| Field | What it does | Consumed by |
|---|---|---|
| `editText` / `highlight` / `selection` | defaults to `primary`; a theme overrides to decouple (e.g. white CTA text on a vivid surface) | value editors, result-card outline, list selection |
| `toolbar: Toolbar?` | nav-bar override: `background` (bar behind menu buttons; `nil` keeps the system `.visible` bar) + `itemBackground` (the chip behind grouped buttons) | `.themedToolbarBackground` |
| `iconColors: [Icon: Color]?` | per-icon colour override for `UIIcon`; may be partial; a present entry wins over the built-in catalog colour | `UIIcon` (see §7) |
| `expandedContentBackground: Color?` | tints a section's *expanded* editor area as a rounded nested panel (leaves the header on `surface`) | `UILayoutSectionView.expandedContent` |
| `pickerDressing: PickerDressing?` | dresses the wheel pickers (expands into the 7 picker fields below); `nil` = `.plain` (native wheel) | the 5 `UIWheel*Themed` wrappers + `.pickerPanel` + `.segmentDressing` |
| `sectionDressing: SectionDressing?` | per-section rainbow/gradient across the 6 input sections | `MainSectionProfileInput` + `.sectionDressed` |
| `glow: GlowDressing?` | neon bloom on every card (+ optional lit-tube core, glowing headings) | `.neonCard` / `.neonGlowBloom` / `.neonHeading` / `.neonTube` |
| `cardFrame: CardFrame?` | an outline drawn around **every** card (input, Calories, macro) | the card views + the joined input card overlay |
| `sectionAccent: Color?` | *internal* — set by `resolved(for:)`, read by `UIIcon`/glow as the section's own hue. Not set by themes directly | `UIIcon`, `neonCard`/`neonHeading` |

### The 7 picker fields (stored on the palette; set via `pickerDressing`)

`ColorPalette` stores these seven; a `PickerDressing` expands into them so the **frozen** picker views
keep reading them by name. `isPickerThemed == (pickerBackground != nil || pickerColorScheme != nil)` is
the switch that selects the *Themed* vs *Plain* wheel at the 8 call sites.

| Field | Effect | Live where |
|---|---|---|
| `pickerBackground` | a rounded-rect panel around each wheel | all themed wheels |
| `pickerColorScheme` | forced `.light`/`.dark` so digits read on a light panel (the `.wheel` style ignores `foregroundStyle`) | all themed wheels |
| `pickerPanelWidth` | insets each wheel into a narrower field | Height / Weight |
| `pickerLabelOffsetX` / `pickerFeetLabelOffsetX` / `pickerFeetInchesLabelOffsetX` | unit-caption x-offsets (the plain *caption-over* layout) | **inert in the caption-beside layout a panel triggers** |
| `pickerWheelSpacing` | gap between the two wheels of a compound unit (feet&inches, stones&pounds) | plain layout |

> **Gotcha:** the four caption/spacing fields are **inert** when a panel is present (Orange/Emerald take
> the caption-beside layout, where the caption sits to the right of the wheel). `.orange` preserves them
> so the preset reproduces exactly what the theme passed; a future plain-layout theme would pick them up.
> See `PickerDressing.orange` and story-024.

---

## 4. How a theme is defined

A `Theme` is a named pair of palettes:

```swift
Theme(id: .myTheme, name: "My Theme", description: "…", light: lightPalette, dark: darkPalette)
// optional: colorScheme: .dark   // pin to one scheme (ignores Appearance) — see §5
// optional: typeface: .sourceSans3
```

`ThemeID` (a `String`, `CaseIterable`, `Identifiable`) names it. `DefaultThemes.all` lists every theme
**in display order** (Default first), and `DefaultThemes.theme(for:)` looks one up, falling back to
`.standard`. Both the `ThemeID` enum and `DefaultThemes.all` must stay in sync — the test
`testAllThemes` asserts they cover the same IDs and `standard` is first.

**`Default` (`standard`) is special:** it is built from *system dynamic colours* (`Color(.systemGroupedBackground)`,
`.primary`, `.secondary`, `.blue`, `.mint`…) so **one** `ColorPalette` serves both schemes, and it is
**exempt** from the contrast test (Apple's `secondaryLabel`/mint fall below the thresholds). The other
13 themes each hand-roll a distinct light **and** dark palette from hex values.

---

## 5. Appearance mode & scheme pinning

`AppearanceMode` (`auto`/`light`/`dark`) is the user's light/dark choice, applied via
`.preferredColorScheme`. It maps to `ColorScheme?` — `auto` → `nil` (system decides).

`Theme.colorScheme` is an **optional pin** that overrides the Appearance choice (e.g. a theme whose
palette only works in dark). `ThemedRoot` applies `theme.colorScheme ?? themeManager.appearance.colorScheme`,
and `ThemeView` **disables the Appearance picker when a theme pins a scheme**.

> **Currently no theme pins a scheme.** The `pride` theme explicitly sets `colorScheme: nil` — its light
> (subtle) and dark (bold) palettes share one theme and follow the user's Appearance. The pin
> capability exists but is unused; add it only for a genuinely single-scheme look.

---

## 6. Resolution flow: how a palette reaches a view

```
TDEEApp.init()  ── ThemeTypography.registerBundledFonts()   // registers SourceSans3, TiltNeon (idempotent)

ThemedRoot(themeManager:)
  └─ PaletteResolver(theme:)  ── palette = theme.palette(for: colorScheme)
        .environment(\.palette, palette)
        .environment(\.themeTypography, theme.typeface ?? .system)
        .tint(palette.primary)
  .preferredColorScheme(theme.colorScheme ?? appearance.colorScheme)
```

Every view reads `@Environment(\.palette)` (and central text components read
`@Environment(\.themeTypography)`). `Color` isn't `Equatable`, so previews/tests compare via a `hex(_:)`
helper (see `ThemeTests`).

### Per-section resolution (`resolved(for:)`)

A `SectionDressing` maps the **6 input sections** (`gender, age, height, weight, activityLevel,
bodyFat` — `SectionDressing.inputSections`) to a `SectionAccent` (a `#hex` swatch + a `mode`). When a
palette carries a `sectionDressing`, `MainSectionProfileInput` wraps each section in
`.sectionDressed(for: icon)`, which runs `SectionDressingModifier`:

1. `resolved = palette.resolved(for: icon)` — substitutes the section's fields:
   - **`.bold`**: fill the section with the swatch (`surface = accent.swatch`); text/selection/CTA become
     `accent.onText` (white or near-black, auto-legible via `Color.legibleText(forHex:)`); the
     wheel/segment panel becomes a **light tint of the swatch** with forced-light digits
     (`.panel(background: accent.panelBackground, appearance: .light, width: 96)`).
   - **`.subtle`**: a light tint of the swatch over the field (`surface = swatch.opacity(subtleIntensity)`);
     text/selection stay the base palette's. The expanded editor panel is `expandedIntensity ??
     min(subtleIntensity + 0.08, 0.5)` (a decoupled, paler editor — Sunflower light uses 0.08).
   - The result always sets `sectionAccent = accent.swatch` and **clears `sectionDressing` → `nil`** so
     resolution never recurses.
2. Injects `resolved` into the environment (so the frozen wheel/segment/icon views cohere to the hue),
   plus `.foregroundStyle(resolved.text)` and `.tint(resolved.sectionAccent ?? resolved.primary)`.
3. Layout: `.joined` → one continuous card (0 pt spacing, the container rounds/shadows); `.separate`
   (default) → each section draws its own rounded card (+ its `glow`).

**Two propagation gotchas (both in `resolved(for:)`):**
- `glow` **is propagated through both branches** — otherwise a dressed section would resolve to
  `glow == nil` and never glow.
- `cardFrame` is **not** propagated — it's a container-level outline the card views (and the joined
  overlay) draw themselves, so it's set on the base palette only.

**Icon colour precedence** (`UIIcon`): `palette.sectionAccent` (a dressed section's hue) →
`palette.iconColors?[icon]` (theme-wide override) → the built-in catalog colour.

---

## 7. Which themes use which extended feature

The headline matrix. "L" = light scheme opts in, "D" = dark scheme opts in, "–" = not used,
"both" = both schemes.

| Theme | typeface | scheme pin | toolbar | iconColors | expandedBG | pickerDressing | sectionDressing | glow | cardFrame |
|---|---|---|---|---|---|---|---|---|---|
| **standard** (Default) | – | – | – | – | – | – | – | – | – |
| **orange** | – | – | both | both | both | D · `.orange` | – | – | – |
| **clouds** | – | – | – | – | – | – | – | – | – |
| **turquoise** | – | – | – | – | – | – | – | – | – |
| **emerald** | – | – | D | D | D | D · `.panel(mint, .light, 96)` | – | – | – |
| **peterRiver** | – | – | – | – | – | – | – | – | – |
| **amethyst** | – | – | – | – | – | – | – | – | – |
| **sunflower** | – | – | both | both | both | – | L `.warmGradient(.subtle, .024, .008, .joined)` · D `.warmGradient(.bold)` | – | L · `#6E4A1E`/2 |
| **carrot** | – | – | – | – | – | – | – | – | – |
| **alizarin** | – | – | – | – | – | – | – | – | – |
| **highContrast** | – | – | – | – | – | – | – | – | – |
| **pride** | – | `nil` | both | – | both | – | L `.pride(.subtle)` · D `.pride(.bold)` | – | – |
| **neon** | `.tiltNeon` | – | both | both | both | – | L `.neon(.subtle,.12)` · D `.neon(.subtle,.10)` | L `.fullLightTube` · D `.full` | – |
| **medical** | `.sourceSans3` | – | both | both | – | – | – | – | – |

**Plain themes** (no extended features — the simplest to reason about): `standard`, `clouds`,
`turquoise`, `peterRiver`, `amethyst`, `carrot`, `alizarin`, `highContrast`.

### How the "rich" themes read

- **Orange** — the reference *dark-field* theme: coral surface on black (dark), warm off-white with a
  deep-coral accent (light). Opt in: `toolbar` + `iconColors` + `expandedContentBackground` on both
  schemes, and the **only dark `pickerDressing` (`.orange`)** — the light scheme's wheel stays plain.
- **Emerald** — like Orange but in greens; its dark scheme is the model for a theme that adopts the
  generic **`.panel(…)`** picker dressing (a light-mint panel, forced-light digits) instead of the
  hand-tuned `.orange` preset.
- **Sunflower** — the **`.joined`** gradient theme: a warm sunset gradient across the 6 input sections.
  Light = `.subtle` + `.joined` (one continuous tinted card, decoupled pale editor via `expandedIntensity
  0.08`) + a `cardFrame` outline; dark = `.bold` (six solid hue cards).
- **Pride** — the per-section **rainbow**: light = `.pride(.subtle)` (tints, plain wheels), dark =
  `.pride(.bold)` (filled swatches, auto-legible text). No `iconColors` — the per-section `sectionAccent`
  wins for the section icons; the result/macro cards read the base palette.
- **Neon** — the **glow** theme + a custom **typeface** (`.tiltNeon`): a faint per-section tint
  (`subtle`) with a crisp outline + bloom in each hue (dark `.full` on near-black; light `.fullLightTube`
  — a lit-tube core + widened halo + near-white heading glow, because a halo is nearly invisible on a
  light field). The `glow` colour per card falls out of `resolved.sectionAccent`, so the rainbow needs no
  per-card field.
- **Medical** — a clean two-palette clinical theme + the other custom **typeface** (`.sourceSans3`);
  a single blue `iconColors` for both schemes, no section dressing, no glow.
- **High Contrast** — not "extended" in feature count, but the only theme the contrast test holds to the
  stricter **7:1** bar for text/primary.

---

## 8. Recipes

### 8.1 Add a new *plain* theme (like Clouds)

1. Add a case to `ThemeID` in `DefaultThemes.swift`.
2. Add `static let myTheme = Theme(id: .myTheme, name: "…", description: "…", light: …, dark: …)` with
   two `ColorPalette`s (10 base roles; leave every extended field at its `nil` default).
3. Append it to `DefaultThemes.all` (this also sets its display position in the picker).
4. Add hex rows to `story-018-themes/palettes.md` and the contrast summary (see §10).
5. Bump `testAllThemes` count + the "one per ID" coverage, and run the suite.

### 8.2 Add a new *dressed* theme (opt in to features)

Start from a plain palette, then set **only** the fields you need:

```swift
// A picker panel like Emerald (one-call opt-in — the recommended route):
pickerDressing: .panel(background: Color(hex: "#A8D5C4"), appearance: .light, width: 96)

// A per-section rainbow/gradient like Pride/Sunflower/Neon:
sectionDressing: .pride(.bold)                 // or .neon(.subtle, subtleIntensity: 0.1), .warmGradient(.subtle, …, layout: .joined)

// A neon bloom like Neon:
glow: .full                                     // .fullLightTube for a light field; customise via the GlowDressing init

// An outline around every card like Sunflower:
cardFrame: CardFrame(color: Color(hex: "#6E4A1E"), width: 2)

// A custom font:
// on the Theme, not the palette:  typeface: .tiltNeon   (register the file in ThemeTypography.registerBundledFonts)
```

**Order of precedence a dressed section resolves to** (§6): `sectionDressing` → per-section
`sectionAccent`/`surface`/`pickerDressing` → then the theme's own `glow`/`cardFrame`/`iconColors`/
`toolbar` fill the result/macro (non-section) cards. You can combine them, as Neon does
(`sectionDressing` + `glow` + `iconColors` + `toolbar` + `typeface`).

### 8.3 Change an existing theme's colours

Edit the two `ColorPalette`s in `DefaultThemes.swift` (and the `palettes.md` table). Keep the contrast
invariants (§10). Prefer a hex that meets the bar; for a per-section bold fill, let
`SectionAccent.onText` choose the legible text — don't hard-code a text colour on a rainbow.

### 8.4 Tune a picker

Tune via the **dressing**, not the view:
- **Reuse**: adopt `.orange`, or call `.panel(background:appearance:width:)` (the caption offsets are
  left `nil` — inert in the caption-beside layout a panel triggers).
- **Add a preset**: add a `static let` to `PickerDressing` (mirrors `.orange`) so the value is one
  source of truth, then adopt it. Do **not** scatter the seven numbers back into a `ColorPalette` init.
- **Never** change the `UIWheel*` views, `pickerPanel`, or the 8 `isPickerThemed` sites — frozen.

### 8.5 Add a new icon

Add a case to `Icon` (`Enums/Icon.swift`) and an entry to the `iconCatalog` in `UIIcon.swift`
(label + solid/outline symbols + a catalog colour). If it's an input section, add it to
`SectionDressing.inputSections` so the named dressings cover it.

---

## 9. The watch

`TDEEWatch/enums/WatchPalette.swift` is a **fixed** palette matching the phone's *Default-dark* look.
**Themes are iPhone-only** — the watch never reads `ThemeManager`/`Theme`/`palette`. Do not wire the
watch to the theme system; change watch colours only in `WatchPalette`.

---

## 10. Invariants & testing (`TDEETests/`)

**`ThemeTests.swift`**
- `testAllThemes`: `DefaultThemes.all` has **14** themes, one per `ThemeID.allCases`, Default first.
  **Bump the count when you add a theme.**
- `testContrast`: every themed palette (Default *exempt*) — `text`/`textSecondary`/`primary` on both
  `surface` and `background` ≥ **4.5:1** (High Contrast ≥ **7:1**); `secondary`/macros on `surface` ≥
  **3:1**. Macros must also stay deuteranopia/protanopia-distinct. Run a contrast pass before landing
  a colour change.
- `testDefaults` / `testPersistenceRoundTrip` / `testInvalidStoredValues`: `ThemeManager` falls back to
  `.standard`/`.auto`; unknown stored values degrade to defaults.
- Share-card image renders at 1080×1350 for **every** `ThemeID` (uses `theme.light`).

**`PickerDressingTests.swift`** — `.plain` is all-`nil`/not themed; `.orange` reproduces its seven
values exactly; `.panel(…)` sets only the panel fields; `ColorPalette(pickerDressing:)` expands a
dressing into the seven stored fields; **every non-Orange/Emerald theme stays undressed** in both
schemes (Orange's *dark* and Emerald's *dark* are the only themed wheels). **Add a themed picker to a
new theme → update `testPlainThemesStayUndressed`.**

**Build/test:** `xcrun xcodebuild -project TDEE.xcodeproj -scheme TDEE -configuration Debug test`
(see `.claude/skills/compile.md`); the booted device target is **iPhone 17 Pro Max / iOS 27.0**.

---

## 11. Gotchas checklist

- **`nil` means "unchanged."** Every extended field is opt-in; adding one is safe for existing themes.
- **Frozen views.** Appearance changes go in the *model* (a palette/dressing); the `UIWheel*` views,
  `pickerPanel`, `UILayoutSectionView`, `ThemeCardView`, `ThemeView` read fields by name and stay put.
- **`resolved(for:)` clears `sectionDressing`** (no recursion) and **propagates `glow` but not
  `cardFrame`** (container-level).
- **The 4 caption/spacing picker fields are inert** in the caption-beside layout a panel triggers;
  keep them on `.orange` for exactness, leave them `nil` on `.panel(…)`.
- **Icon precedence:** `sectionAccent` → `iconColors` → catalog. A dressed section ignores
  `iconColors` for its own icon.
- **Bold section text is auto-legible** (`SectionAccent.onText` / `Color.legibleText`); don't pin a
  text colour on a rainbow fill.
- **Typeface lives on `Theme`, not `ColorPalette`;** register any new bundled font in
  `ThemeTypography.registerBundledFonts` (the family name must match the font file's `name` table or the
  role silently falls back to the system face).
- **`ThemeID` and `DefaultThemes.all` must stay in sync** (and Default stays first).
- **Default is exempt** from the contrast test by design — don't "fix" its sub-threshold system colours.
- **`Color` isn't `Equatable`** — compare via `hex(_:)` in tests/previews.
- **`ColorPalette` is built only in `DefaultThemes.swift`** (and the watch's `WatchPalette`) — a change
  to its init is contained to those call sites.
