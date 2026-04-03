import SwiftUI

struct WheelPickerAgeView: View {
    
    @Binding var value: Int
    var optionsAge: [Int] = Array(16...99)
    
    var body: some View {
        ZStack {
            
            Picker("age", selection: $value) {
                ForEach(optionsAge, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            
            UITextPickerLabel("age in years")
                .offset(x: 60)
            
        }
    }
}

struct PickerAgeView_Previews: PreviewProvider {
    @State static var selectedAge: Int = 21
    
    static var previews: some View {
        
        WheelPickerAgeView(value: $selectedAge)
    }
}
