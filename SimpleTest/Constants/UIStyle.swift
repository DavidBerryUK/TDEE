//
//  UIStyle.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UIStyle {
    
    struct Text {
        static let macroProtein = Color.red.opacity(0.85)
        static let macroCarbs   = Color.blue
        static let macroFats    = Color.mint
        
        static let fontColorEditError = Color.red
        static let fontColorReadOnlyError = Color.red.opacity(0.5) // You can adjust the opacity as needed

        static let fontColorReadOnly = Color.gray
        static let fontWeightReadOnly: Font.Weight = .regular
        
        static let fontColorEdit = Color.red
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
