import SwiftUI

struct WheelPickerAgeView: View {
    
    @Binding var value: Int
    var optionsAge: [Int] = Array(16...99)
    
    var body: some View {
        Picker("age", selection: $value) {
            ForEach(optionsAge, id: \.self) { value in
                Text("\(value)").tag(value)
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
}

struct PickerAgeView_Previews: PreviewProvider {
    @State static var selectedAge: Int = 21
    
    static var previews: some View {
        // Make sure the binding value exists in pickerData
        WheelPickerAgeView(value: $selectedAge)
    }
}
