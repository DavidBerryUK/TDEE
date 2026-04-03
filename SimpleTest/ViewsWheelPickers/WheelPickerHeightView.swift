import SwiftUI

struct WheelPickerHeightView: View {
    
    @Binding var value: Int
    
    @State private  var valueKg: Int = 1
    @State private  var valueStones: Int = 1
    @State private  var valuePounds: Int = 1
    
    var optionsKg: [Int] = Array(0...99)
    var optionsStones: [Int] = Array(0...25)
    var optionsPounds: [Int] = Array(0...14)
    
    var body: some View {
        HStack{
            
            VStack{
                Text("Kg")
                Picker("Kg", selection: $valueKg) {
                    ForEach(optionsKg, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            
            VStack{
                Text("Stones")
                Picker("Stones", selection: $valueStones) {
                    ForEach(optionsStones, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            
            VStack{
                Text("Pounds")
                Picker("Pounds", selection: $valuePounds) {
                    ForEach(optionsPounds, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
        }
    }
}

struct PickerWeightView_Previews: PreviewProvider {
    @State static var selectedHeight: Int = 21
    
    static var previews: some View {
        // Make sure the binding value exists in pickerData
        WheelPickerHeightView(value: $selectedHeight
        )
    }
}
