//
//  ColorExtensions.swift
//  TempProteinFatsCarbsMixer
//
//  Created by David Berry on 18/04/2026.
//

import SwiftUI

extension Color {
    
    func readableTextColor() -> Color {
        let uiColor = UIColor(self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Standard luminance formula
        let luminance = (0.299 * red + 0.587 * green + 0.114 * blue)
        
        return luminance > 0.6 ? .black : .white
    }
    
    
}
