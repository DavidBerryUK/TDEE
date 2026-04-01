import SwiftUI

struct CalculationResultsView: View {
    @ObservedObject var profile: ProfileInputViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Results")
                .font(.title3).bold()

            Group {
//                HStack { Text("Age"); Spacer(); Text("\(profile.gender)") }
                HStack { Text("Gender"); Spacer(); Text("\(profile.gender)") }
                HStack { Text("Age"); Spacer(); Text("\(profile.age)") }
                HStack { Text("Height"); Spacer(); Text("\(profile.height)") }
                HStack { Text("Weight"); Spacer(); Text("\(profile.weight)") }
//                HStack { Text("Body Fat"); Spacer(); Text("\(profile.bodyFatPercentage)") }
            }
            .font(.body)
            .foregroundStyle(.primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            CalculationResultsView(profile: ProfileInputViewModel())
        }
        .padding()
    }
}
