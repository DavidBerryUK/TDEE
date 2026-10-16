//
//  SwiftUIView.swift
//  TDEE
//
//  Created by David Berry on 02/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a segmented control for gender selection.
// The options are: Male, Female.
// The .pickerStyle(.segmented) is intentional - segmented controls are best for short option lists.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// DO NOT remove any option cases - both genders are required for BMR calculation.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UISegmentGenderView: View {

    @Binding var option: Gender

    var body: some View {
        Picker("Gender", selection: $option) {
            ForEach(Gender.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("Gender")
    }
}

#Preview {
    @Previewable @State var option: Gender = Gender.male
    UISegmentGenderView(option: $option)
}
