//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a segmented control for macro split method selection.
// The options are: Custom, Ketogenic, Low Carb, High Carb, Balanced.
// The .pickerStyle(.segmented) is intentional - segmented controls are best for short option lists.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// DO NOT remove any option cases - all methods are required for macro calculation.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UISegmentMacroSplitMethodView: View {

    @Binding var option: MacroSplitMethod

    var body: some View {
        Picker("Macro Split", selection: $option) {
            ForEach(MacroSplitMethod.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("macroSplitMethodSelector")
    }
}

#Preview {
    @Previewable @State var option: MacroSplitMethod = MacroSplitMethod.custom
    UISegmentMacroSplitMethodView(option: $option)
}
