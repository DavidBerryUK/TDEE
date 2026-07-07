//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentCalorieAdjustmentMethodView: View {

    @Binding var option: enumCalorieAdjustmentMethod

    var body: some View {
        Picker("Calories", selection: $option) {
            ForEach(enumCalorieAdjustmentMethod.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: enumCalorieAdjustmentMethod = enumCalorieAdjustmentMethod.maintain
    UISegmentCalorieAdjustmentMethodView(option: $option)
}
