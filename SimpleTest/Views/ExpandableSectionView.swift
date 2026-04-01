import SwiftUI

struct ExpandableSectionView<M: SectionViewModelIdentifiable>: View {
    @ObservedObject var model: M
    var section: AppEnums.enumSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(model.title)
                    .font(.headline)
                Spacer()
                Image(systemName: model.isExpanded ? "chevron.up" : "chevron.down")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    model.isExpanded.toggle()
                }
            }

            Text(model.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if model.isExpanded {
                Divider()
                Text(model.details)
                    .font(.body)
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
        .animation(.default, value: model.isExpanded)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            ExpandableSectionView(model: SectionAgeViewModel(), section: AppEnums.enumSection.age)
        }
        .padding()
    }
}
