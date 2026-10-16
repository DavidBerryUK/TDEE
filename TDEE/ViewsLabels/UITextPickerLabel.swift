//
//  UITextPickerLabel.swift
//  TDEE
//
//  Created by David Berry on 03/04/2026.
//

import SwiftUI

struct UITextPickerLabel: View {
    @Environment(\.palette) private var palette
    let text: String
    
    init(_ text: String = "") {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .allowsHitTesting(false)
            .font(.footnote)
            .foregroundStyle(palette.textSecondary)
    }
}

#Preview {

    UITextPickerLabel("age in years")
}
