//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostWheelPickerBodyFat: View {
    @State private var bodyFatPercentage: Double = 15.7 // example starting value
    
    var body: some View {
        TestHostContainer(
            title: "Body Fat Picker Test",
            instructions: "Use the picker below to select a body fat percentage. This is a test host for the HostWheelPickerBodyFat control.",
            content: {UIWheelPickerBodyFatView(value: $bodyFatPercentage)},
            valueView: {
                Text("Selected Body Fat: \(bodyFatPercentage) %")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}


#Preview {
    NavigationStack {
        HostWheelPickerBodyFat()
    }
}
