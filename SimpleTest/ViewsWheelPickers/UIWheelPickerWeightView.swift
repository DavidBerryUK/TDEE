import SwiftUI

import SwiftUI

struct UIWheelPickerWeightView: View {
    
    //
    // weight value is always in kilograms
    //
    @Binding var value: Double
    @Binding var unitOfMeasure: enumOptionWeight
    
    @State private var valueKg: Int = 1
    @State private var valueStones: Int = 1
    @State private var valueStonePounds: Int = 1
    @State private var valuePounds: Int = 1
    
    var optionsKg: [Int] = Array(0...250)
    var optionsPounds: [Int] = Array(0...550)
    var optionsStones: [Int] = Array(0...40)
    var optionsStonePounds: [Int] = Array(0...13)
    
    var body: some View {
        
        let viewIsKg = unitOfMeasure == .kilograms
        let viewIsPounds = unitOfMeasure == .pounds
        let viewIsStonesAndPounds = unitOfMeasure == .stonesAndPounds
        
        ZStack {
            
            // KG
            UIPickerKgView
                .opacity(viewIsKg ? 1 : 0)
                .offset(y: viewIsKg ? 0 : 12)
                .scaleEffect(viewIsKg ? 1 : 0.98)
                .allowsHitTesting(viewIsKg)
            
            // Pounds
            UIPickerPoundsView
                .opacity(viewIsPounds ? 1 : 0)
                .offset(y: viewIsPounds ? 0 : 12)
                .scaleEffect(viewIsPounds ? 1 : 0.98)
                .allowsHitTesting(viewIsPounds)
            
            // Stones + Pounds
            UIPickerStonesAndPoundsView
                .opacity(viewIsStonesAndPounds ? 1 : 0)
                .offset(y: viewIsStonesAndPounds ? 0 : 12)
                .scaleEffect(viewIsStonesAndPounds ? 1 : 0.98)
                .allowsHitTesting(viewIsStonesAndPounds)
        }
        .frame(height: 150) // prevents layout jumping
        .animation(.easeInOut(duration: 0.2), value: unitOfMeasure)
    }
}

private extension UIWheelPickerWeightView {
    
    var UIPickerKgView: some View {
        ZStack {
            Picker("Kg", selection: $valueKg) {
                ForEach(optionsKg, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            
            UITextPickerLabel("kg")
                .offset(x: 40)
        }
    }
    
    var UIPickerPoundsView: some View {
        ZStack {
            Picker("Pounds", selection: $valuePounds) {
                ForEach(optionsPounds, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            
            UITextPickerLabel("pounds")
                .offset(x: 40)
        }
    }
    
    var UIPickerStonesAndPoundsView: some View {
        HStack {
            
            ZStack {
                Picker("Stones", selection: $valueStones) {
                    ForEach(optionsStones, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                
                UITextPickerLabel("stones")
                    .offset(x: 36)
            }
            
            ZStack {
                Picker("Pounds", selection: $valueStonePounds) {
                    ForEach(optionsStonePounds, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                
                UITextPickerLabel("pounds")
                    .offset(x: 36)
            }
        }
    }
}



#Preview("kg") {
    @Previewable @State var weightInKg: Double = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.kilograms
    UIWheelPickerWeightView(value: $weightInKg, unitOfMeasure: $unitOfMeasure)
}

#Preview("Pounds") {
    @Previewable @State var weightInKg: Double = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.pounds
    UIWheelPickerWeightView(value: $weightInKg, unitOfMeasure: $unitOfMeasure)
}

#Preview("Stones and Pounds") {
    @Previewable @State var weightInKg: Double = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.stonesAndPounds
    UIWheelPickerWeightView(value: $weightInKg, unitOfMeasure: $unitOfMeasure)
}
