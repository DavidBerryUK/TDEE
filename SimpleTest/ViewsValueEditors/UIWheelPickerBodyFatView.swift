import SwiftUI

struct UIWheelPickerBodyFatView: View {
    
    @Binding var value: Double
    
    @State private var valueInteger: Int = 0
    @State private var valueDecimal: Int = 0
    
    var optionsInteger: [Int] = Array(0...99)
    var optionsDecimal: [Int] = Array(0...9)
    
    var body: some View {
        HStack(spacing: 4) {
            
            Picker("Integer", selection: $valueInteger) {
                ForEach(optionsInteger, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 110)   // key change
            
            Text(".")
                .foregroundStyle(.secondary)
                .fontWeight(.black)
            
            Picker("Decimal", selection: $valueDecimal) {
                ForEach(optionsDecimal, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 110)   // key change
            
            Text("%")
                .foregroundStyle(.secondary)
                .padding(.leading, 2) // keeps it tight to picker
        }
        .padding(.horizontal, 16) // page padding
        .onChange(of: valueInteger) {
            updateValue()
        }
        .onChange(of: valueDecimal) {
            updateValue()
        }
        .onAppear {
            // initialise from binding
            valueInteger = Int(value)
            valueDecimal = Int((value * 10).truncatingRemainder(dividingBy: 10))
        }
    }
    
    private func updateValue() {
        value = Double(valueInteger) + Double(valueDecimal) / 10.0
    }
}

#Preview() {
    @Previewable @State var bodyFat: Double = 15.7
    UIWheelPickerBodyFatView(value: $bodyFat)
}
