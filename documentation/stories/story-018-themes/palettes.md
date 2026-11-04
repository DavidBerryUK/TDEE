# Story 018: Theme Palettes

**Default** reproduces the app's current colours: iOS system colours, the system blue accent (`AccentColor` is unset), and macros of red at 85% opacity, blue and mint. It should be implemented with **system dynamic colours** (`Color(.systemGroupedBackground)`, `.primary`, `.secondary`, `.blue`, `.mint`, etc.), not these hex values. The hex values are the iOS 17+ resolved equivalents, used for previews and documentation. Default is **exempt** from the contrast checks: in light mode, Apple's `secondaryLabel` (3.4:1) and mint (2.1:1) fall below the thresholds the other themes meet.

The other themes are each built on one Flat UI hue. Accents are shifted in lightness to meet contrast, and backgrounds are lightly tinted. Macro colours (protein pink, carbs blue, fat yellow) are shared across those themes.

Checks (all themes except Default): text and primary ≥ 4.5:1 (High Contrast ≥ 7:1); secondary and macros ≥ 3:1 vs surface; macros distinguishable under deuteranopia and protanopia simulation (Default passes this). Preview: [palette-preview.html](palette-preview.html).


## Default

The app's current look: iOS system colours, blue accent

| Token | Light | Dark |
|---|---|---|
| `primary` | `#007AFF` | `#0A84FF` |
| `secondary` | `#FF3B30` | `#FF453A` |
| `background` | `#F2F2F7` | `#000000` |
| `surface` | `#FFFFFF` | `#1C1C1E` |
| `text` | `#000000` | `#FFFFFF` |
| `textSecondary` | `#8A8A8E` | `#98989F` |
| `border` | `#C6C6C8` | `#38383A` |
| `macroProtein` | `#FF584F` | `#DD3F36` |
| `macroCarbs` | `#007AFF` | `#0A84FF` |
| `macroFat` | `#00C7BE` | `#63E6E2` |

## Clouds

Calm greys with a wet-asphalt accent

| Token | Light | Dark |
|---|---|---|
| `primary` | `#34495E` | `#95A5A6` |
| `secondary` | `#7F8C8D` | `#7F8C8D` |
| `background` | `#F4F6F7` | `#121619` |
| `surface` | `#FFFFFF` | `#1C2226` |
| `text` | `#1E2A36` | `#ECF0F1` |
| `textSecondary` | `#536476` | `#92A1A6` |
| `border` | `#D5DBDF` | `#222C34` |
| `macroProtein` | `#E91E63` | `#E91E63` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## Turquoise

Fresh turquoise and green-sea

| Token | Light | Dark |
|---|---|---|
| `primary` | `#117D68` | `#1ABC9C` |
| `secondary` | `#34495E` | `#587CA0` |
| `background` | `#EFFAF8` | `#0F1D1E` |
| `surface` | `#FFFFFF` | `#1A3232` |
| `text` | `#1B383E` | `#ECF0F1` |
| `textSecondary` | `#46787C` | `#8DB8B2` |
| `border` | `#D1F2EB` | `#1A554D` |
| `macroProtein` | `#E91E63` | `#E91E63` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## Emerald

Natural greens

| Token | Light | Dark |
|---|---|---|
| `primary` | `#1D8148` | `#2ECC71` |
| `secondary` | `#16A085` | `#16A085` |
| `background` | `#F0FBF5` | `#101E1B` |
| `surface` | `#FFFFFF` | `#1C342D` |
| `text` | `#1D3A39` | `#ECF0F1` |
| `textSecondary` | `#49786F` | `#91BBAA` |
| `border` | `#D5F5E3` | `#205A3E` |
| `macroProtein` | `#E91E63` | `#E92366` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## Peter River

Clear sky blue

| Token | Light | Dark |
|---|---|---|
| `primary` | `#1F74AE` | `#3D9CDD` |
| `secondary` | `#17A388` | `#1ABC9C` |
| `background` | `#F1F8FC` | `#111A22` |
| `surface` | `#FFFFFF` | `#1D2E3A` |
| `text` | `#1E3445` | `#ECF0F1` |
| `textSecondary` | `#507490` | `#92B1BF` |
| `border` | `#D6EAF8` | `#234862` |
| `macroProtein` | `#E91E63` | `#E91E63` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## Amethyst

Rich purple

| Token | Light | Dark |
|---|---|---|
| `primary` | `#9650B2` | `#B17EC6` |
| `secondary` | `#E91E63` | `#E91E63` |
| `background` | `#F8F3FA` | `#18161F` |
| `surface` | `#FFFFFF` | `#292636` |
| `text` | `#2A2C41` | `#ECF0F1` |
| `textSecondary` | `#6C688C` | `#A7A4B8` |
| `border` | `#EBDEF0` | `#463356` |
| `macroProtein` | `#E91E63` | `#E91E63` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## Sunflower

Warm sunshine yellow

| Token | Light | Dark |
|---|---|---|
| `primary` | `#886E08` | `#F1C40F` |
| `secondary` | `#DF7619` | `#E67E22` |
| `background` | `#FEFBEE` | `#1E1E14` |
| `surface` | `#FFFFFF` | `#343321` |
| `text` | `#35392D` | `#ECF0F1` |
| `textSecondary` | `#747457` | `#B8BA96` |
| `border` | `#FCF3CF` | `#63571D` |
| `macroProtein` | `#E91E63` | `#EB2E6E` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## Carrot

Energetic orange

| Token | Light | Dark |
|---|---|---|
| `primary` | `#AB5A13` | `#E67E22` |
| `secondary` | `#D35400` | `#D35400` |
| `background` | `#FDF6F0` | `#1D1915` |
| `surface` | `#FFFFFF` | `#322A24` |
| `text` | `#33312F` | `#ECF0F1` |
| `textSecondary` | `#7B6D64` | `#B6AC9A` |
| `border` | `#FAE5D3` | `#5F3F24` |
| `macroProtein` | `#E91E63` | `#E91E63` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## Alizarin

Bold red

| Token | Light | Dark |
|---|---|---|
| `primary` | `#D32B1A` | `#EB675A` |
| `secondary` | `#C0392B` | `#D03E2F` |
| `background` | `#FDF2F1` | `#1D1517` |
| `surface` | `#FFFFFF` | `#332427` |
| `text` | `#332B32` | `#ECF0F1` |
| `textSecondary` | `#80656E` | `#B6A29F` |
| `border` | `#FADBD8` | `#602E2C` |
| `macroProtein` | `#E91E63` | `#E91E63` |
| `macroCarbs` | `#3498DB` | `#3498DB` |
| `macroFat` | `#AE8E0A` | `#F1C40F` |

## High Contrast

Maximum legibility, single strong accent

| Token | Light | Dark |
|---|---|---|
| `primary` | `#0033CC` | `#7FB2FF` |
| `secondary` | `#000000` | `#FFFFFF` |
| `background` | `#EBEBEB` | `#000000` |
| `surface` | `#FFFFFF` | `#1A1A1A` |
| `text` | `#000000` | `#FFFFFF` |
| `textSecondary` | `#262626` | `#E0E0E0` |
| `border` | `#000000` | `#FFFFFF` |
| `macroProtein` | `#A3001B` | `#FF8C9E` |
| `macroCarbs` | `#0033CC` | `#7FB2FF` |
| `macroFat` | `#B36B00` | `#FFC94D` |

## Neon

Per-section electric rainbow with a glow — a restrained glowing "neon card" on every scheme: neon-on-dark (a near-black field) and neon-on-light (a cooler, deeper grey field + a lit-tube core). The only theme that sets the new `glow` field (`GlowDressing`): a crisp rounded-rect outline plus a layered-shadow bloom on every card, and glowing section headings. On a light field an outer halo is nearly invisible, so the light scheme adds a `tubeCore` — a bright inner line on every card outline (the "lit tube") — and sits on a deeper grey so the halo has a ground to read against. Each input card is a faint tint of its hue with a solid glowing border in that hue (dark `subtleIntensity 0.1` matches the result/macro boxes' 0.1 fill; light uses 0.12) via `SectionDressing.neon(.subtle)`; the result/macro cards glow the house cyan. No `colorScheme` pin, so the user's Appearance choice decides which shows.

| Token | Light | Dark |
|---|---|---|
| `primary` | `#005FBF` | `#19E6FF` |
| `secondary` | `#B0006A` | `#FF2E9A` |
| `background` | `#DCE2F1` | `#0A0A10` |
| `surface` | `#F0F3FB` | `#14141C` |
| `text` | `#141026` | `#F2F6FF` |
| `textSecondary` | `#5B5E7A` | `#9DA3C9` |
| `border` | `#C7D1E6` | `#2A2A40` |
| `macroProtein` | `#C2185B` | `#FF2E9A` |
| `macroCarbs` | `#0072BC` | `#19E6FF` |
| `macroFat` | `#AE8E0A` | `#FFD23F` |
| `glow` | `fullLightTube` — stroke `#005FBF`, core r1.5/0.6, halo r9/0.32, tube core white 0.75/inset 0.6 | `full` — stroke `#19E6FF`, core r2.5/0.95, halo r16/0.5 |

Section hues (one table, both schemes, via `SectionDressing.neon(.subtle)`): gender `#1E5CFF`, age `#E6007A`, height `#F0C000`, weight `#00B85C`, activityLevel `#E65100`, bodyFat `#9B2BFF`. Each card is the hue tinted (dark 10%, light 12%) with a solid border and glow in the full hue; light adds a white tube core on the outline. Text is the scheme's base colour (light on dark, deep ink on light).

## Contrast summary (vs surface)

| Theme | Mode | text | textSecondary | primary | lowest macro |
|---|---|---|---|---|---|
| Default | light | 21.0 | 3.4 | 4.0 | 2.1 |
| Default | dark | 17.0 | 5.9 | 4.7 | 3.9 |
| Clouds | light | 14.6 | 6.1 | 9.3 | 3.1 |
| Clouds | dark | 14.0 | 6.0 | 6.3 | 3.7 |
| Turquoise | light | 12.5 | 5.0 | 5.1 | 3.1 |
| Turquoise | dark | 11.8 | 6.2 | 5.6 | 3.1 |
| Emerald | light | 12.2 | 5.0 | 4.9 | 3.1 |
| Emerald | dark | 11.6 | 6.3 | 6.3 | 3.1 |
| Peter River | light | 12.9 | 5.0 | 5.0 | 3.1 |
| Peter River | dark | 12.2 | 6.2 | 4.7 | 3.2 |
| Amethyst | light | 13.7 | 5.3 | 5.1 | 3.1 |
| Amethyst | dark | 12.8 | 6.1 | 4.7 | 3.4 |
| Sunflower | light | 11.8 | 4.8 | 4.9 | 3.1 |
| Sunflower | dark | 11.1 | 6.4 | 7.7 | 3.1 |
| Carrot | light | 13.0 | 5.0 | 5.0 | 3.1 |
| Carrot | dark | 12.3 | 6.3 | 4.9 | 3.2 |
| Alizarin | light | 13.7 | 5.2 | 5.1 | 3.1 |
| Alizarin | dark | 12.9 | 6.1 | 4.7 | 3.4 |
| High Contrast | light | 21.0 | 15.1 | 9.0 | 4.2 |
| High Contrast | dark | 17.4 | 13.2 | 8.1 | 7.9 |
| Neon | light | 18.55 | 6.31 | 6.20 | 3.15 |
| Neon | dark | 16.92 | 7.43 | 12.04 | 5.33 |
