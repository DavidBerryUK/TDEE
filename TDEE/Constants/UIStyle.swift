//
//  UIStyle.swift
//  TDEE
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UIStyle {

    struct Text {
        /// Font weight for read-only text
        static let fontWeightReadOnly: Font.Weight = .regular

        /// Font weight for edit fields
        static let fontWeightEdit: Font.Weight = .bold
    }
}

/// Resolves section value text styling. Colours come from the active theme palette;
/// error colours stay system red in every theme.
struct UITextStyleResolver {

    static func fontColor(_ palette: ColorPalette, isExpanded: Bool, isError: Bool? = nil) -> Color {
        if let isError = isError {
            // If isError is provided (either true or false), return the appropriate color
            return isError ? .red : palette.textSecondary
        } else {
            // If isError is nil, return the default color based on isExpanded
            return isExpanded ? palette.editText : palette.textSecondary
        }
    }

    static func fontWeight(isExpanded: Bool) -> Font.Weight {
        isExpanded ? UIStyle.Text.fontWeightEdit : UIStyle.Text.fontWeightReadOnly
    }

    static func unitOfMeasureColor(_ palette: ColorPalette, isError: Bool? = nil) -> Color {
        if let isError = isError, isError {
            return .red
        } else {
            return palette.text // Default color for units of measure when not in error
        }
    }
}
