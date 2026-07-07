import SwiftUI

struct UIWheelPickerActivityLevelView: View {

    @Binding var value: enumActivityLevel

    var body: some View {
        VStack {
            Text("Activity Level")
                .accessibilityLabel("Activity level selector")

            Picker("Activity Level", selection: $value) {
                ForEach(enumActivityLevel.allCases, id: \.self) { level in
                    Text(level.displayName)
                        .tag(level) // ✅ enum, not Int
                }
            }
            .pickerStyle(.wheel)
            .accessibilityLabel("Activity level picker")
            .accessibilityValue("Current: \(value.displayName)")
        }
    }
}

struct PickerActivityLevel_Previews: PreviewProvider {
    @State static var option : enumActivityLevel = enumActivityLevel.sedentary
    
    static var previews: some View {
        // Make sure the binding value exists in pickerData
        UIWheelPickerActivityLevelView(value: $option)
    }
}
