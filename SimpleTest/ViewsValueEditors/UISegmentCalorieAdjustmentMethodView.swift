//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

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
        .accessibilityLabel("Calorie adjustment method selector")
        .accessibilityValue("Current: \(option.displayName)")
    }
}

#Preview {
    @Previewable @State var option: CalorieAdjustmentMethod = CalorieAdjustmentMethod.maintain
    UISegmentCalorieAdjustmentMethodView(option: $option)
}
