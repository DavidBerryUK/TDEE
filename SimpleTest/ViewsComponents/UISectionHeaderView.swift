import SwiftUI

struct UISectionHeaderView: View {
    let title: String
    @Binding var isExpanded: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        UISectionHeaderView(title: "Age", isExpanded: .constant(false))
        UISectionHeaderView(title: "Age", isExpanded: .constant(true))
    }
    .padding()
}
