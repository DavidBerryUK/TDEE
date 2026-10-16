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
| `background` | `#FFFFFF` | `#000000` |
| `surface` | `#FFFFFF` | `#000000` |
| `text` | `#000000` | `#FFFFFF` |
| `textSecondary` | `#262626` | `#E0E0E0` |
| `border` | `#000000` | `#FFFFFF` |
| `macroProtein` | `#A3001B` | `#FF8C9E` |
| `macroCarbs` | `#0033CC` | `#7FB2FF` |
| `macroFat` | `#B36B00` | `#FFC94D` |

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
| High Contrast | dark | 21.0 | 15.9 | 9.7 | 9.5 |
