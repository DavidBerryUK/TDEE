import SwiftUI

struct WheelPickerActivityLevelView: View {
    
    @Binding var value: AppEnums.enumActivityLevel
    
    var body: some View {
        VStack {
            Text("Activity Level")
            
            Picker("Activity Level", selection: $value) {
                ForEach(AppEnums.enumActivityLevel.allCases, id: \.self) { level in
                    Text(level.displayName)
                        .tag(level) // ✅ enum, not Int
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct PickerActivityLevel_Previews: PreviewProvider {
    @State static var option : AppEnums.enumActivityLevel = AppEnums.enumActivityLevel.Sedentary
    
    static var previews: some View {
        // Make sure the binding value exists in pickerData
        WheelPickerActivityLevelView(value: $option)
    }
}
