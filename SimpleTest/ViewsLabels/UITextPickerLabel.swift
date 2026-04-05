//
//  UITextPickerLabel.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//

import SwiftUI

struct UITextPickerLabel: View {
    let text: String
    
    init(_ text: String = "") {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .allowsHitTesting(false)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

#Preview {

    UITextPickerLabel("age in years")
}
