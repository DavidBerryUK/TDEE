//
//  HostPickerAge.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostWheelPickerActivityLevel: View {
    @State private var activityLevel: enumActivityLevel = enumActivityLevel.sedentary
    
    var body: some View {
        TestHostContainer(
            title: "Activity Level Picker Test",
            instructions: "Use the picker below to select an activity level. This is a test host for the WheelPickerActivityLevelView control."
        ) {
            VStack {
                WheelPickerActivityLevelView(value: $activityLevel)
                Text("Activity Level: \(activityLevel)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    HostWheelPickerActivityLevel()
}
