import SwiftUI

struct SectionGenderView: View {
    @ObservedObject var model: ProfileInputViewModel
    
    let title: String = "Gender"
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
            
            }
            .contentShape(Rectangle())
            Text("Gender")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Picker("Gender", selection: $model.gender) {
                Text("0").tag(0)
                Text("1").tag(1)
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .animation(.default, value: model.genderIsExpanded)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            SectionGenderView(model: ProfileInputViewModel())
        }
        .padding()
    }
}
