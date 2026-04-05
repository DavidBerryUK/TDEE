import SwiftUI

struct UIWheelPickerHeightView: View {
    
    @Binding var value: Double
    @Binding var unitOfMeasure : enumOptionLength
    
    @State private  var valueCm: Int = 0
    @State private  var valueInches: Int = 0
    @State private  var valueFeet: Int = 0
    @State private  var valueFeetInches: Int = 0
    
    // Animation Constants
    let animOffsetOffset : CGFloat = 24
    let animOffsetNone : CGFloat = 0
    let animZoomOut : CGFloat = 0.98
    let animZoomFull : CGFloat = 1.00
    let animOpacityClear : CGFloat = 0
    let animOpacitySolid : CGFloat = 1
    let animDuration : CGFloat = 0.30
    
    // Options
    var optionsCm: [Int] = Array(0...272)
    var optionsInches: [Int] = Array(0...107)
    var optionsFeet: [Int] = Array(0...8)
    var optionsFeetInches: [Int] = Array(0...11)
    
    var body: some View {
        
        let showCm : Bool = (unitOfMeasure == enumOptionLength.centimeters)
        let showInches : Bool = (unitOfMeasure == enumOptionLength.inches)
        let showFeetAndInches : Bool = (unitOfMeasure == enumOptionLength.feetAndInches)
        
        ZStack{

            UIPickerViewCentimeters
                .opacity(showCm ? animOpacitySolid : animOpacityClear)
                .offset(y: showCm ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showCm ? animZoomFull : animZoomOut)
                .allowsHitTesting(showCm)
            
            
            UIPickerViewInches
                .opacity(showInches ? animOpacitySolid : animOpacityClear)
                .offset(y: showInches ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showInches ? animZoomFull : animZoomOut)
                .allowsHitTesting(showInches)
            
            UIPickerViewFeetAndInches
                .opacity(showFeetAndInches ? animOpacitySolid : animOpacityClear)
                .offset(y: showFeetAndInches ? animOffsetNone : animOffsetOffset)
                .scaleEffect(showFeetAndInches ? animZoomFull : animZoomOut)
                .allowsHitTesting(showFeetAndInches)
        }
        .frame(height: 150)
        .animation(.easeInOut(duration: animDuration), value: unitOfMeasure)
        .onAppear {
            initialiseValues()
        }
        .onChange(of: unitOfMeasure) { oldMeasure, _ in
            syncStateFromPreviousUnit(oldMeasure: oldMeasure)
        }
        .onChange(of: valueCm) { _, newValue in
            convertFromCmToValue(cm: newValue)
        }
        .onChange(of: valueInches) { _, newValue in
            convertFromInchesToValue(inches: newValue)
        }
        .onChange(of: valueFeet) { _, newValue in
            convertFromFeetAndInchesToValue(feet: newValue, inches: valueFeetInches)
        }
        .onChange(of: valueFeetInches) { _, newValue in
            convertFromFeetAndInchesToValue(feet: valueFeet, inches: newValue)
        }
    }
}

private extension UIWheelPickerHeightView {
    
    func initialiseValues() {
        valueCm = Int(round( value))
        let totalInches = LengthConverter.toInches(valueCm)
        valueInches = totalInches
        valueFeet = totalInches / 12
        valueFeetInches = totalInches % 12
    }
    
    func syncStateFromPreviousUnit(oldMeasure: enumOptionLength) {
        
        switch oldMeasure
        {
        case .centimeters:
            let totalInches = LengthConverter.toInches(valueCm)
            valueInches = totalInches
            valueFeet = totalInches / 12
            valueFeetInches = totalInches % 12
            break
            
        case .inches:
            let totalInches = valueInches
            valueCm = LengthConverter.toCentimeters(totalInches)
            valueFeet = totalInches / 12
            valueFeetInches = totalInches % 12
            break
            
        case .feetAndInches:
            let totalInches = valueFeet * 12 + valueFeetInches
            valueCm = LengthConverter.toCentimeters(totalInches)
            valueInches = totalInches
            break
        }
    }
    
    func convertFromCmToValue(cm: Int) {
        guard unitOfMeasure == .centimeters else { return }
        value = Double(cm)
    }
    
    func convertFromInchesToValue(inches: Int) {
        guard unitOfMeasure == .inches else { return }
        let cm = LengthConverter.toCentimeters(inches)
        value = Double(cm)
    }
    
    func convertFromFeetAndInchesToValue(feet: Int, inches: Int) {
        guard unitOfMeasure == .feetAndInches else { return }
        let totalInches = (feet * 12) + inches
        let cm = LengthConverter.toCentimeters(totalInches)
        value = Double(cm)
    }
}

private extension UIWheelPickerHeightView {
    
    var UIPickerViewCentimeters : some View {
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
    
    var UIPickerViewInches : some View {
        ZStack{
            
            Picker("Inches", selection: $valueInches) {
                ForEach(optionsInches, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(WheelPickerStyle())
            UITextPickerLabel("inches")
                .offset(x: 40)
        }
    }
    
    var UIPickerViewFeetAndInches : some View {
        HStack{
            ZStack{
                Picker("feet", selection: $valueFeet) {
                    ForEach(optionsFeet, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                UITextPickerLabel("feet")
                    .offset(x: 36)
            }
            
            ZStack{
                Picker("Inches", selection: $valueFeetInches) {
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

#Preview("Centimeters") {
    @Previewable @State var selectedHeight: Double = 200
    @Previewable @State var unitOfMeasure : enumOptionLength = enumOptionLength.centimeters
    UIWheelPickerHeightView(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}

#Preview("Inches") {
    @Previewable @State var selectedHeight: Double = 200
    @Previewable @State var unitOfMeasure : enumOptionLength = enumOptionLength.inches
    UIWheelPickerHeightView(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}

#Preview("Feet and Inches") {
    @Previewable @State var selectedHeight: Double = 200
    @Previewable @State var unitOfMeasure : enumOptionLength = enumOptionLength.feetAndInches
    UIWheelPickerHeightView(value: $selectedHeight, unitOfMeasure: $unitOfMeasure)
}
