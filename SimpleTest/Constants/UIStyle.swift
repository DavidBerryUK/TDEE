//
//  UIStyle.swift
//  SimpleTest
//
//  Created by David Berry on 04/04/2026.
//

import SwiftUI

struct UIStyle {
    
    struct Text {
        static let colorReadOnly = Color.gray
        static let weightReadOnly: Font.Weight = .regular
        
        static let colorEdit = Color.red
        static let weightEdit: Font.Weight = .bold
    }
}

struct UITextStyleResolver {
    
    static func color(isExpanded: Bool) -> Color {
        isExpanded
        ? UIStyle.Text.colorEdit
        : UIStyle.Text.colorReadOnly
    }
    
    static func weight(isExpanded: Bool) -> Font.Weight {
        isExpanded
        ? UIStyle.Text.weightEdit
        : UIStyle.Text.weightReadOnly
    }
}
