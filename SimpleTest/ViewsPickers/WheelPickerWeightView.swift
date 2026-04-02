import SwiftUI

struct WheelPickerWeightView: View {
    
    @Binding var value: Int
    
    @State private  var valueKg: Int = 1
    @State private  var valueStones: Int = 1
    @State private  var valueStonePounds: Int = 1
    @State private  var valuePounds: Int = 1
    
    var optionsKg: [Int] = Array(0...250)
    var optionsPounds: [Int] = Array(0...550)
    var optionsStones: [Int] = Array(0...40)
    var optionsStonePounds: [Int] = Array(0...13)
    
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
                Picker("Pounds", selection: $valueStonePounds) {
                    ForEach(optionsStonePounds, id: \.self) { value in
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

struct PickerHeightView_Previews: PreviewProvider {
    @State static var selectedWeight: Int = 21
    
    static var previews: some View {
        // Make sure the binding value exists in pickerData
        WheelPickerWeightView(value: $selectedWeight)
    }
}
