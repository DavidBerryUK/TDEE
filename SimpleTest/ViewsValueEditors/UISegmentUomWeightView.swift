//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a segmented control for weight unit of measure selection (kg/lb/stones).
// The .pickerStyle(.segmented) is intentional - segmented controls are best for short option lists.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// DO NOT remove any option cases - all unit options are required for conversion.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UISegmentUomWeightView: View {

    @Binding var option: OptionWeight

    var body: some View {
        Picker("Weight", selection: $option) {
            ForEach(OptionWeight.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("weightUnitSelector")
    }
}

#Preview {
    @Previewable @State var option: OptionWeight = OptionWeight.kilograms
    UISegmentUomWeightView(option: $option)
}
