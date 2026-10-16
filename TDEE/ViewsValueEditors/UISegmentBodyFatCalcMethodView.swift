//
//  SwiftUIView.swift
//  TDEE
//
//  Created by David Berry on 02/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a segmented control for body fat calculation method selection.
// The three options are: Omit, Estimate, Manual Entry.
// The .pickerStyle(.segmented) is intentional - segmented controls are best for short option lists.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// DO NOT remove any option cases - all methods are required for the expanding panel logic.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UISegmentBodyFatCalcMethodView: View {

    @Binding var option: BodyFatOption

    var body: some View {
        Picker("BodyFatOption", selection: $option) {
            ForEach(BodyFatOption.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("bodyFatMethodSegmentedControl")
    }
}

#Preview {
    @Previewable @State var option: BodyFatOption = BodyFatOption.omit
    UISegmentBodyFatCalcMethodView(option: $option)
}
