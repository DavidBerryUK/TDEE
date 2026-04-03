import SwiftUI

struct WheelPickerBodyFatView: View {
    
    @Binding var value: Double
    
    @State private var valueInteger: Int = 0
    @State private var valueDecimal: Int = 0
    
    var optionsInteger: [Int] = Array(0...99)
    var optionsDecimal: [Int] = Array(0...9)
    
    var body: some View {
        HStack {
            Picker("Integer", selection: $valueInteger) {
                ForEach(optionsInteger, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            
            Text(".")
                .foregroundStyle(.secondary)
                .fontWeight(.black)
            
            Picker("Decimal", selection: $valueDecimal) {
                ForEach(optionsDecimal, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
        }
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
