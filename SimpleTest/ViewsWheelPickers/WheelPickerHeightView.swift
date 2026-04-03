import SwiftUI

struct WheelPickerHeightView: View {
    
    @Binding var value: Int
    @Binding var unitOfMeasure : enumOptionLength
    
    @State private  var valueCm: Int = 1
    @State private  var valueStones: Int = 1
    @State private  var valuePounds: Int = 1
    
    var optionsCm: [Int] = Array(0...272)
    var optionsInches: [Int] = Array(0...107)
    var optionsFeet: [Int] = Array(0...8)
    var optionsFeetInches: [Int] = Array(0...11)
    
    var body: some View {
        
        let showCm : Bool = (unitOfMeasure == enumOptionLength.centimeters)
        let showInches : Bool = (unitOfMeasure == enumOptionLength.inches)
        let showFeetAndInches : Bool = (unitOfMeasure == enumOptionLength.feetAndInches)
        
        HStack{
            
            if (showCm) {
                ZStack{
                    
                    Picker("Cm", selection: $valueCm) {
                        ForEach(optionsCm, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    UITextPickerLabel("centimeters")
                        .offset(x: 60)
                }
            }
            
            if (showInches)
            {
                ZStack{

                    Picker("Inches", selection: $valueStones) {
                        ForEach(optionsInches, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    UITextPickerLabel("inches")
                        .offset(x: 40)
                }
            }
            
            if (showFeetAndInches) {
                HStack{
                    ZStack{
                        Picker("feet", selection: $valuePounds) {
                            ForEach(optionsFeet, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        UITextPickerLabel("feet")
                            .offset(x: 36)
                    }
                 
                    ZStack{
                        Picker("Inches", selection: $valuePounds) {
                            ForEach(optionsFeetInches, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        UITextPickerLabel("inches")
                            .offset(x: 36)
                    }
                }
            }
        }
    }
}

#Preview("Centimeters") {
    @Previewable @State var selectedHeight: Int = 21
    @Previewable @State var unitOfMeasure : enumOptionLength = enumOptionLength.centimeters
    WheelPickerHeightView(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}

#Preview("Inches") {
    @Previewable @State var selectedHeight: Int = 21
    @Previewable @State var unitOfMeasure : enumOptionLength = enumOptionLength.inches
    WheelPickerHeightView(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}

#Preview("Feet and Inches") {
    @Previewable @State var selectedHeight: Int = 21
    @Previewable @State var unitOfMeasure : enumOptionLength = enumOptionLength.feetAndInches
    WheelPickerHeightView(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}
