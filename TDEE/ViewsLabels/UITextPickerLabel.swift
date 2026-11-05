//
//  UITextPickerLabel.swift
//  TDEE
//
//  Created by David Berry on 03/04/2026.
//

import SwiftUI

struct UITextPickerLabel: View {
    @Environment(\.palette) private var palette
    @Environment(\.themeTypography) private var typography
    // Re-resolve the custom family on a Dynamic Type change (a no-op for the system-font themes).
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let text: String
    
    init(_ text: String = "") {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .allowsHitTesting(false)
            .font(typography.footnote)
            .foregroundStyle(palette.textSecondary)
    }
}

#Preview {

    UITextPickerLabel("age in years")
}
