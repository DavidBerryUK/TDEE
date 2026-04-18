//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostWheelPickerWeight: View {
    @State private var weightInKg: Double = 70 // example starting value
    @State private var unitOfMeasure: enumOptionWeight = enumOptionWeight.kilograms
    
    var body: some View {
        TestHostContainer(
            title: "Weight Picker Test",
            instructions: "Use the picker below to select a weight. This is a test host for the WheelPickerWeightView control.",
            content: {UIWheelPickerWeightView(value: $weightInKg, unitOfMeasure: $unitOfMeasure)},
            inputView:{ UISegmentUomWeightView(option: $unitOfMeasure) },
            valueView: {
                Text("Selected Weight: \(weightInKg) kg")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}


#Preview {
    NavigationStack {
        HostWheelPickerWeight()
    }
}
