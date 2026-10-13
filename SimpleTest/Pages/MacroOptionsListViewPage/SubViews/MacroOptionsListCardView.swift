import SwiftUI

struct MacroOptionsListCardView: View {

    @Environment(MacroSplitOptionsModelCollection.self)
    var collection

    @Bindable var item: MacroSplitOptionModel
    @Binding var path: [AppRoute]

    func handleOnDelete(item: MacroSplitOptionModel) {
        collection.remove(item)
    }

    func handleOnEdit(item: MacroSplitOptionModel) {
        path.append(.macroEditorEdit(item))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header: Name
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            // Macro color bands
            GeometryReader { geo in
                let total = item.protein + item.carbs + item.fats
                let availableWidth = geo.size.width - 6

                HStack(spacing: 2) {
                    macroSegment(
                        color: UIStyle.Text.macroProtein,
                        value: item.protein,
                        total: total,
                        availableWidth: availableWidth
                    )

                    macroSegment(
                        color: UIStyle.Text.macroCarbs,
                        value: item.carbs,
                        total: total,
                        availableWidth: availableWidth
                    )

                    macroSegment(
                        color: UIStyle.Text.macroFats,
                        value: item.fats,
                        total: total,
                        availableWidth: availableWidth
                    )
                }
            }
            .frame(height: 24)

            // Macro details as clean list
            HStack(spacing: 16) {
                macroDetail(
                    icon: "bolt.fill",
                    color: UIStyle.Text.macroProtein,
                    text: "protein \(item.protein)%"
                )
                macroDetail(
                    icon: "leaf.fill",
                    color: UIStyle.Text.macroCarbs,
                    text: "carbs \(item.carbs)%"
                )
                macroDetail(
                    icon: "drop.fill",
                    color: UIStyle.Text.macroFats,
                    text: "fats \(item.fats)%"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)

        // Tap to edit
        .onTapGesture {
            handleOnEdit(item: item)
        }

        // Swipe actions
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                handleOnEdit(item: item)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                handleOnDelete(item: item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func macroSegment(color: Color, value: Int, total: Int, availableWidth: CGFloat) -> some View {
        let width = availableWidth * CGFloat(value) / CGFloat(max(total, 1))

        color
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .frame(width: max(width, 4))
    }

    @ViewBuilder
    private func macroDetail(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

#Preview {
    MacroOptionsListCardView(
        item: MacroSplitOptionModel(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Balanced",
            protein: 34,
            carbs: 33,
            fats: 33,
            ordinal: 1
        ),
        path: .constant([])
    )
    .environment(MacroSplitOptionsModelCollection())
}
