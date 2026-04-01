import SwiftUI

struct SectionWeightView: View {
    @ObservedObject var model: ProfileInputViewModel
    let title: String = "Weight"
    let summary: String = "Enter Weight Here"
    let details: String = "Some made up stuff about weight"

    private var isExpanded: Binding<Bool> {
        Binding(
            get: { model.weightIsExpanded },
            set: { model.weightIsExpanded = $0 }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderView(title: title, isExpanded: isExpanded)

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if isExpanded.wrappedValue {
                Divider()
                
                HStack(spacing: 12) {
                    TextField("Weight", value: $model.weight, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 80)

                    Stepper(value: $model.weight, in: 0...130) {
                        Text("\(model.weight)")
                            .monospacedDigit()
                    }
                    .labelsHidden()
                }
                .foregroundStyle(.primary)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            SectionWeightView(model: ProfileInputViewModel())
        }
        .padding()
    }
}
