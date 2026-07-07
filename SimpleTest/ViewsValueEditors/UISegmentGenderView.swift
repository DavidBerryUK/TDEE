//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentGenderView: View {

    @Binding var option: enumGender

    var body: some View {
        Picker("Gender", selection: $option) {
            ForEach(enumGender.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Gender selector")
        .accessibilityValue("Current: \(option.displayName)")
    }
}

#Preview {
    @Previewable @State var option: enumGender = enumGender.male
    UISegmentGenderView(option: $option)
}
