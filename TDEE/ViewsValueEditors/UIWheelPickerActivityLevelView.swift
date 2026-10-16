//
//  UIWheelPickerActivityLevelView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: DO NOT MODIFY THIS FILE UNDER ANY CIRCUMSTANCES.
// This file contains a wheel picker for activity level selection.
// The .pickerStyle(.wheel) is intentional - wheel pickers are best for ordered categorical values.
// DO NOT change to .pickerStyle(.menu) which would create a dropdown.
// APPROVAL REQUIRED BEFORE ANY MODIFICATIONS.

import SwiftUI

struct UIWheelPickerActivityLevelView: View {

    @Binding var value: ActivityLevel

    var body: some View {
        VStack {
            Text("Activity Level")
                .accessibilityLabel("Activity level selector")

            Picker("Activity Level", selection: $value) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Text(level.displayName)
                        .tag(level) // ✅ enum, not Int
                }
            }
            .pickerStyle(.wheel)
            .accessibilityIdentifier("activityLevelPicker")
        }
    }
}

struct PickerActivityLevel_Previews: PreviewProvider {
    @State static var option : ActivityLevel = ActivityLevel.sedentary

    static var previews: some View {
        // Make sure the binding value exists in pickerData
        UIWheelPickerActivityLevelView(value: $option)
    }
}
