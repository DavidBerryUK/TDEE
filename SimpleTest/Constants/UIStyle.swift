//
//  UIStyle.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UIStyle {

    struct Text {
        /// Protein macro color with opacity for visual distinction (0.85)
        static let macroProtein = Color.red.opacity(0.85)

        /// Carbohydrate macro color
        static let macroCarbs   = Color.blue

        /// Fat macro color
        static let macroFats    = Color.mint

        /// Error color for edit fields
        static let fontColorEditError = Color.red

        /// Error color for read-only fields with reduced opacity (0.5)
        static let fontColorReadOnlyError = Color.red.opacity(0.5) // You can adjust the opacity as needed

        /// Default color for read-only text
        static let fontColorReadOnly = Color.gray

        /// Font weight for read-only text
        static let fontWeightReadOnly: Font.Weight = .regular

        /// Color for edit fields
        static let fontColorEdit = Color.red

        /// Font weight for edit fields
        static let fontWeightEdit: Font.Weight = .bold

    }
}

struct UITextStyleResolver {
    
    static func fontColor(isExpanded: Bool, isError: Bool? = nil) -> Color {
        if let isError = isError {
            // If isError is provided (either true or false), return the appropriate color
            return isError ? UIStyle.Text.fontColorEditError : UIStyle.Text.fontColorReadOnly
        } else {
            // If isError is nil, return the default color based on isExpanded
            return isExpanded ? UIStyle.Text.fontColorEdit : UIStyle.Text.fontColorReadOnly
        }
    }
    
    static func fontWeight(isExpanded: Bool) -> Font.Weight {
        isExpanded ? UIStyle.Text.fontWeightEdit : UIStyle.Text.fontWeightReadOnly
    }
    
    static func unitOfMeasureColor(isError: Bool? = nil) -> Color {
        if let isError = isError, isError {
            return .red
        } else {
            return .primary // Default color for units of measure when not in error
        }
    }
}
