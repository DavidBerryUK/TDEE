//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostWheelPickerWeight: View {
    @State private var selectedWeight: Int = 70 // example starting value
    
    var body: some View {
        TestHostContainer(
            title: "Weight Picker Test",
            instructions: "Use the picker below to select a weight. This is a test host for the WheelPickerWeightView control.",
            content: {WheelPickerWeightView(value: $selectedWeight)},
            valueView: {
                Text("Selected Weight: \(selectedWeight) kg")
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
