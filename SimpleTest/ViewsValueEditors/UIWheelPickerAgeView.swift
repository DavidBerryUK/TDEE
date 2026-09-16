import SwiftUI

struct UIWheelPickerAgeView: View {

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
            .accessibilityLabel("Age picker")
            .accessibilityIdentifier("agePicker")
            .accessibilityValue("Current age: \(value) years")

            UITextPickerLabel("age in years")
                .offset(x: 60)
        }
    }
}

#Preview("age") {
    @Previewable @State var selectedAge: Int = 21
    UIWheelPickerAgeView(value: $selectedAge)
}
