//
//  SwiftUIView.swift
//  TDEE
//
//  Created by David Berry on 02/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a segmented control for height unit of measure selection (cm/inches/feet).
// The .pickerStyle(.segmented) is intentional - segmented controls are best for short option lists.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// DO NOT remove any option cases - all unit options are required for conversion.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UISegmentUomLengthView: View {

    @Binding var option: OptionLength

    var body: some View {
        Picker("Length", selection: $option) {
            ForEach(OptionLength.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("heightUnitSelector")
    }
}

#Preview {
    @Previewable @State var option: OptionLength = OptionLength.centimeters
    UISegmentUomLengthView(option: $option)
}
