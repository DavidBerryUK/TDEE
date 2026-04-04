//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSegmentCalorieAdjustmentMethod: View {
    @State private var option: enumCalorieAdjustmentMethod = enumCalorieAdjustmentMethod.maintain
    
    var body: some View {
        TestHostContainer(
            title: "Segment - Calorie Adjustment Method",
            instructions: "Use the select below to select the Calorie Adjustment Method. This is a test host for the HostSegmentCalorieAdjustmentMethod control.",
            content:{UISegmentCalorieAdjustmentMethodView(option: $option)},
            valueView:{
                Text("Gender: \(option.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSegmentCalorieAdjustmentMethod()
    }
}
