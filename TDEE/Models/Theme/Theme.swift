//
//  Theme.swift
//  TDEE
//

import SwiftUI

/// The colour roles every view draws from. See documentation/stories/story-018-themes/palettes.md.
struct ColorPalette {
    let primary: Color
    let secondary: Color
    let background: Color
    let surface: Color
    let text: Color
    let textSecondary: Color
    let border: Color
    let macroProtein: Color
    let macroCarbs: Color
    let macroFat: Color
    /// Text of the field being edited (an expanded section's value).
    let editText: Color
    /// Outline of highlighted result cards (e.g. daily/weekly calories).
    let highlight: Color
    /// Marks the selected item in a list (e.g. the active macro preset).
    let selection: Color

    /// Optional navigation-bar override. `nil` (the default) keeps the app's system bar.
    let toolbar: Toolbar?
    /// Optional per-icon colour for `UIIcon`. `nil` keeps each icon's built-in catalog colour;
    /// a present entry (the map may be partial) wins for that icon.
    let iconColors: [Icon: Color]?

    /// Background of a section's *expanded* content area, drawn beneath the editor while the section
    /// is open. `nil` (the default) leaves the content on the section's `surface`; a value tints just
    /// the expanded region, so it reads as a distinct panel while the header stays on `surface`.
    let expandedContentBackground: Color?

    /// The wheel picker's own panel background, drawn as a rounded rect *around* the picker so its
    /// highlighted row reads against a distinct field. `nil` (the default) leaves the picker on the
    /// section surface; a value insets just the picker into that tint while the picker's label (e.g.
    /// "age in years") stays outside the rect, on the section content.
    let pickerBackground: Color?

    /// The wheel picker's appearance override, so its rows read on a light panel. The `.wheel` style
    /// is a `UIPickerView` that draws its rows in the system label colour and ignores `foregroundStyle`,
    /// so on a light panel the digits stay light and wash out; forcing `.light` here makes the rows
    /// render dark. `nil` (the default) keeps the picker on the app's scheme, correct on every other
    /// theme's dark surface.
    let pickerColorScheme: ColorScheme?

    /// The wheel picker's fixed panel width, so a theme can inset each wheel into a narrower field.
    /// `nil` (the default) leaves the panel at the wheel's natural width.
    let pickerPanelWidth: CGFloat?

    /// The wheel picker's unit-caption x-offset (the "cm"/"inches"/"feet"/"inches" label). `nil`
    /// (the default) keeps each wheel's own caption position; a value shifts the caption so it can
    /// sit outside a narrowed panel.
    let pickerLabelOffsetX: CGFloat?

    /// The feet wheel's ("feet") caption x-offset within a compound unit (feet & inches). Kept separate
    /// from `pickerLabelOffsetX` because the same centre-offset can't give "feet" (a short label) and
    /// "inches" (a longer one) equal gaps from their panels. `nil` (the default) falls back to
    /// `pickerLabelOffsetX`, then the wheel's own position, so a theme that doesn't set it is unchanged.
    let pickerFeetLabelOffsetX: CGFloat?

    /// The feet-&-inches wheel's ("inches" caption) x-offset within a compound unit. See
    /// `pickerFeetLabelOffsetX`; `nil` (the default) falls back to `pickerLabelOffsetX`.
    let pickerFeetInchesLabelOffsetX: CGFloat?

    /// The gap between the two wheels of a compound unit (feet & inches, stones & pounds), so a unit
    /// caption can sit *between* them. `nil` (the default) uses the group's natural spacing.
    let pickerWheelSpacing: CGFloat?

    /// Whether the theme dresses the wheel picker — a panel or a forced appearance. A parent shows the
    /// themed wheel (`UIWheelXxxThemed`) when this is true and the plain wheel (`UIWheelXxxPlain`)
    /// otherwise; every theme that doesn't opt in leaves both picker fields `nil`, so its wheels stay
    /// plain.
    var isPickerThemed: Bool {
        pickerBackground != nil || pickerColorScheme != nil
    }

    /// How a theme overrides the navigation bar. A `nil` `background` keeps
    /// `.toolbarBackground(.visible, for: .navigationBar)`.
    struct Toolbar {
        /// The bar behind the menu buttons; `nil` keeps the system `.visible` bar.
        var background: Color?
        /// The chip the system draws behind the grouped menu buttons; `nil` keeps the system grey.
        var itemBackground: Color?
        init(background: Color? = nil, itemBackground: Color? = nil) {
            self.background = background
            self.itemBackground = itemBackground
        }
    }

    /// `editText`, `highlight` and `selection` default to `primary`; Default overrides them
    /// to keep the app's original red, teal and green. `toolbar`/`iconColors`/`expandedContentBackground`
    /// default to `nil`, so every theme keeps today's system bar, icon colours and content background
    /// unless it opts in. The picker's seven fields come from one adopted `pickerDressing` (a
    /// `PickerDressing`; `nil` = `.plain`/undressed), so a theme dresses its wheels by adopting a
    /// dressing rather than setting seven numbers. The fields stay stored on the palette — the frozen
    /// picker views read them by name — so the dressing is the model-layer generalisation and the views
    /// stay untouched.
    init(
        primary: Color, secondary: Color, background: Color, surface: Color,
        text: Color, textSecondary: Color, border: Color,
        macroProtein: Color, macroCarbs: Color, macroFat: Color,
        editText: Color? = nil, highlight: Color? = nil, selection: Color? = nil,
        toolbar: Toolbar? = nil, iconColors: [Icon: Color]? = nil,
        expandedContentBackground: Color? = nil,
        pickerDressing: PickerDressing? = nil
    ) {
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.surface = surface
        self.text = text
        self.textSecondary = textSecondary
        self.border = border
        self.macroProtein = macroProtein
        self.macroCarbs = macroCarbs
        self.macroFat = macroFat
        self.editText = editText ?? primary
        self.highlight = highlight ?? primary
        self.selection = selection ?? primary
        self.toolbar = toolbar
        self.iconColors = iconColors
        self.expandedContentBackground = expandedContentBackground
        // The picker's seven fields come from one adopted `PickerDressing`, expanded here so the stored
        // fields — which the frozen picker views read by name — keep their names; `nil` is `.plain`
        // (undressed, the app's original wheel).
        let dressing = pickerDressing ?? .plain
        self.pickerBackground = dressing.background
        self.pickerColorScheme = dressing.colorScheme
        self.pickerPanelWidth = dressing.panelWidth
        self.pickerLabelOffsetX = dressing.labelOffsetX
        self.pickerFeetLabelOffsetX = dressing.feetLabelOffsetX
        self.pickerFeetInchesLabelOffsetX = dressing.feetInchesLabelOffsetX
        self.pickerWheelSpacing = dressing.wheelSpacing
    }
}

/// A named theme with a palette for each colour scheme.
struct Theme: Identifiable {
    let id: ThemeID
    let name: String
    let description: String
    let light: ColorPalette
    let dark: ColorPalette
    /// Pins the app to one colour scheme, overriding the Appearance setting. For themes whose
    /// palette only works one way (Orange's black field needs dark-mode system text, e.g. nav
    /// titles and list headers); `nil` (the default) follows the user's Appearance choice.
    var colorScheme: ColorScheme? = nil

    func palette(for colorScheme: ColorScheme) -> ColorPalette {
        colorScheme == .dark ? dark : light
    }
}

extension Color {
    /// Creates a colour from a `#RRGGBB` hex string. Invalid input gives black.
    init(hex: String) {
        let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt32(digits, radix: 16) ?? 0
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
