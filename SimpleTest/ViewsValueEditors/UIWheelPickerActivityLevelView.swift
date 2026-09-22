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
