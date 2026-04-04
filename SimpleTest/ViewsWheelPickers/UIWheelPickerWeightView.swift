import SwiftUI

struct UIWheelPickerWeightView: View {
    
    //
    // Source of truth: always kilograms
    //
    @Binding var value: Double
    @Binding var unitOfMeasure: enumOptionWeight
    
    // Picker state
    @State private var valueKg: Int = 0
    @State private var valuePounds: Int = 0
    @State private var valueStones: Int = 0
    @State private var valueStonePounds: Int = 0
    
    // Animation Constants
    let animOffsetUp : CGFloat = -24
    let animOffsetDown : CGFloat = 24
    let animOffsetNone : CGFloat = 0
    let animZoomOut : CGFloat = 0.98
    let animZoomFull : CGFloat = 1.00
    let animOpacityClear : CGFloat = 0
    let animOpacitySolid : CGFloat = 1
    let animDuration : CGFloat = 0.30
    
    // Options
    var optionsKg: [Int] = Array(0...250)
    var optionsPounds: [Int] = Array(0...550)
    var optionsStones: [Int] = Array(0...40)
    var optionsStonePounds: [Int] = Array(0...13)
    
    var body: some View {
        
        let viewIsKg = unitOfMeasure == .kilograms
        let viewIsPounds = unitOfMeasure == .pounds
        let viewIsStonesAndPounds = unitOfMeasure == .stonesAndPounds

        return ZStack {
            
            // KG
            UIPickerKgView
                .opacity(viewIsKg ? animOpacitySolid : animOpacityClear)
                .offset(y: viewIsKg ? animOffsetNone : animOffsetDown)
                .scaleEffect(viewIsKg ? animZoomFull : animZoomOut)
                .allowsHitTesting(viewIsKg)
            
            // Pounds
            UIPickerPoundsView
                .opacity(viewIsPounds ? animOpacitySolid : animOpacityClear)
                .offset(y: viewIsPounds ? animOffsetNone : animOffsetDown)
                .scaleEffect(viewIsPounds ? animZoomFull : animZoomOut)
                .allowsHitTesting(viewIsPounds)
            
            // Stones + Pounds
            UIPickerStonesAndPoundsView
                .opacity(viewIsStonesAndPounds ? animOpacitySolid : animOpacityClear)
                .offset(y: viewIsStonesAndPounds ? animOffsetNone : animOffsetDown)
                .scaleEffect(viewIsStonesAndPounds ? animZoomFull : animZoomOut)
                .allowsHitTesting(viewIsStonesAndPounds)
        }
        .frame(height: 150)
        .animation(.easeInOut(duration: animDuration), value: unitOfMeasure)
        .onAppear {
            initialiseValues()
        }
        .onChange(of: unitOfMeasure) { oldMeasure, newMeasure in
            syncStateFromPreviousUnit(oldMeasure: oldMeasure)
        }
        .onChange(of: valueKg) { _, newValue in
            convertFromKgToValue(kg: newValue)
        }
        .onChange(of: valuePounds) { _, newValue in
            convertFromPoundsToValue(pounds: newValue)
        }
        .onChange(of: valueStones) { _, newValue in
            convertFromStonesAndPoundsToValue(stones: newValue, pounds: valueStonePounds)
        }
        .onChange(of: valueStonePounds) { _, newValue in
            convertFromStonesAndPoundsToValue(stones: valueStones, pounds: newValue)
        }
    }
}

private extension UIWheelPickerWeightView {
    
    func initialiseValues() {
        valueKg = Int(round( value))
        let totalPounds = ConversionUtility.ToPounds(kilograms: valueKg)
        valuePounds = totalPounds
        valueStones = totalPounds / 14
        valueStonePounds = totalPounds % 14
    }
    
    func syncStateFromPreviousUnit(oldMeasure: enumOptionWeight) {
        
        switch oldMeasure
        {
        case .kilograms:
            let totalPounds = ConversionUtility.ToPounds(kilograms: valueKg)
            valuePounds = totalPounds
            valueStones = totalPounds / 14
            valueStonePounds = totalPounds % 14
            break
            
        case .pounds:
            let totalPounds = valuePounds
            valueKg = ConversionUtility.ToKilograms(pounds: totalPounds)
            valueStones = totalPounds / 14
            valueStonePounds = totalPounds % 14
            break
            
        case .stonesAndPounds:
            let totalPounds = valueStones * 14 + valueStonePounds
            valueKg = ConversionUtility.ToKilograms(pounds: totalPounds)
            valuePounds = totalPounds
            break
        }
    }
    
    func convertFromKgToValue(kg: Int) {
        guard unitOfMeasure == .kilograms else { return }
        value = Double(kg)
    }
    
    func convertFromPoundsToValue(pounds: Int) {
        guard unitOfMeasure == .pounds else { return }
        let kg = ConversionUtility.ToKilograms(pounds: pounds)
        value = Double(kg)
    }
    
    func convertFromStonesAndPoundsToValue(stones: Int, pounds: Int) {
        guard unitOfMeasure == .stonesAndPounds else { return }
        let totalPounds = (stones * 14) + pounds
        let kg = ConversionUtility.ToKilograms(pounds: totalPounds)
        value = Double(kg)
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
                .offset(x: 36)
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
                .offset(x: 50)
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
    @Previewable @State var value: Double = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.kilograms
    UIWheelPickerWeightView(value: $value, unitOfMeasure: $unitOfMeasure)
}

#Preview("Pounds") {
    @Previewable @State var value: Double = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.pounds
    UIWheelPickerWeightView(value: $value, unitOfMeasure: $unitOfMeasure)
}

#Preview("Stones and Pounds") {
    @Previewable @State var weightInKg: Double = 21
    @Previewable @State var unitOfMeasure : enumOptionWeight = enumOptionWeight.stonesAndPounds
    UIWheelPickerWeightView(value: $weightInKg, unitOfMeasure: $unitOfMeasure)
}
