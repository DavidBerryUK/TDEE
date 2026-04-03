import SwiftUI

struct WheelPickerWeightView: View {
    
    @Binding var value: Int
    @Binding var unitOfMeasure : enumOptionWeight
    
    @State private  var valueKg: Int = 1
    @State private  var valueStones: Int = 1
    @State private  var valueStonePounds: Int = 1
    @State private  var valuePounds: Int = 1
    
    var optionsKg: [Int] = Array(0...250)
    var optionsPounds: [Int] = Array(0...550)
    var optionsStones: [Int] = Array(0...40)
    var optionsStonePounds: [Int] = Array(0...13)
    
    var body: some View {
        
        let showKg : Bool = (unitOfMeasure == enumOptionWeight.kilograms)
        let showPounds : Bool = (unitOfMeasure == enumOptionWeight.pounds)
        let showStonesAndPounds : Bool = (unitOfMeasure == enumOptionWeight.stonesAndPounds)
        
        HStack{
            
            if ( showKg)
            {
                ZStack{
                    Picker("Kg", selection: $valueKg) {
                        ForEach(optionsKg, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    UITextPickerLabel("kg")
                        .offset(x: 40)
                }
            }
            
            if ( showPounds)
            {
                ZStack{
                    Picker("Pounds", selection: $valueStones) {
                        ForEach(optionsPounds, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    UITextPickerLabel("pounds")
                        .offset(x: 40)
                }
            }
            
            if ( showStonesAndPounds)
            {
                HStack{
                    ZStack{
                        Picker("Stones", selection: $valueStones) {
                            ForEach(optionsStones, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }.pickerStyle(WheelPickerStyle())
                        UITextPickerLabel("stones")
                            .offset(x: 36)
                    }
                    
                    ZStack{
                        Picker("Pounds", selection: $valueStonePounds) {
                            ForEach(optionsStonePounds, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        UITextPickerLabel("pounds")
                            .offset(x: 36)
                    }
                    
                }
            }
        }
    }
}



#Preview("kg") {
    @Previewable @State var value: Int = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.kilograms
    WheelPickerWeightView(value: $value, unitOfMeasure: $unitOfMeasure)
}

#Preview("Pounds") {
    @Previewable @State var value: Int = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.pounds
    WheelPickerWeightView(value: $value, unitOfMeasure: $unitOfMeasure)
}

#Preview("Stones and Pounds") {
    @Previewable @State var value: Int = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.stonesAndPounds
    WheelPickerWeightView(value: $value, unitOfMeasure: $unitOfMeasure)
}
