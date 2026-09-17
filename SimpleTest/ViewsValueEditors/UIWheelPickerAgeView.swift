import SwiftUI

struct UIWheelPickerAgeView: View {

    @Binding var value: Int
    var optionsAge: [Int] = Array(16...99)

    var body: some View {
        HStack {
            Picker("age", selection: $value) {
                ForEach(optionsAge, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .accessibilityLabel("Age picker")
            .accessibilityIdentifier("agePicker")
            .accessibilityValue("Current age: \(value) years")

            Spacer()

            Text("age in years")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("age") {
    @Previewable @State var selectedAge: Int = 21
    UIWheelPickerAgeView(value: $selectedAge)
}
