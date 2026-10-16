//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a segmented control for calorie adjustment method selection.
// The options are: Maintain, Cut, Bulk.
// The .pickerStyle(.segmented) is intentional - segmented controls are best for short option lists.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// DO NOT remove any option cases - all methods are required for the expanding panel logic.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UISegmentCalorieAdjustmentMethodView: View {

    @Binding var option: CalorieAdjustmentMethod

    var body: some View {
        Picker("Calorie adjustment method", selection: $option) {
            ForEach(CalorieAdjustmentMethod.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("calorieAdjustmentMethodSelector")
    }
}

#Preview {
    @Previewable @State var option: CalorieAdjustmentMethod = CalorieAdjustmentMethod.maintain
    UISegmentCalorieAdjustmentMethodView(option: $option)
}
