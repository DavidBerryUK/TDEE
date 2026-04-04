//
//  HostPickerHeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostWheelPickerHeight: View {
    @State private var selectedHeight: Double = 170 // example starting value
    @State private var unitOfMeasure: enumOptionLength = enumOptionLength.centimeters
    
    var body: some View {
        TestHostContainer(
            title: "Height Picker Test",
            instructions: "Use the picker below to select a height. This is a test host for the WheelPickerHeightView control.",
            content: { UIWheelPickerHeightView(value: $selectedHeight, unitOfMeasure: $unitOfMeasure) },
            inputView:{ UISegmentUomLengthView(option: $unitOfMeasure) },
            valueView: { Text("Selected Height: \(selectedHeight) cm")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostWheelPickerHeight()
    }
}
