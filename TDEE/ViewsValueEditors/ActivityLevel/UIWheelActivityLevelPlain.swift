//
//  UIWheelActivityLevelPlain.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

// AI AGENT WARNING: the .pickerStyle(.wheel) is intentional — a wheel is best for ordered categorical
// values, not a dropdown. This is the PLAIN activity-level wheel: the raw SwiftUI .pickerStyle(.wheel)
// with no theme dressing. Its themed sibling (a ThemedWheelPicker with a themed selection band) is
// UIWheelActivityLevelThemed; a parent shows one or the other based on the active theme.
// Renamed from UIWheelPickerActivityLevelView as part of the story-023 Themed/Plain split.

import SwiftUI

struct UIWheelActivityLevelPlain: View {

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
        UIWheelActivityLevelPlain(value: $option)
    }
}
