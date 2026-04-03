//
//  HostPickerAge.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostWheelPickerAge: View {
    @State private var selectedAge: Int = 21
    
    var body: some View {
        TestHostContainer(
            title: "Age Picker Test",
            instructions: "Use the picker below to select an age. This is a test host for the WheelPickerAgeView control."
        ) {
            VStack {
                WheelPickerAgeView(value: $selectedAge)
                Text("Selected Age: \(selectedAge)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    HostWheelPickerAge()
}
