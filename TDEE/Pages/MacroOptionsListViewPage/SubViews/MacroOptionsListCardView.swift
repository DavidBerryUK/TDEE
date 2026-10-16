import SwiftUI

struct MacroOptionsListCardView: View {
    @Environment(\.palette) private var palette

    @Environment(MacroSplitOptionsModelCollection.self)
    var collection

    @Bindable var item: MacroSplitOptionModel
    @Binding var path: [AppRoute]
    @Binding var selectedMacroId: UUID

    func handleOnDelete(item: MacroSplitOptionModel) {
        collection.remove(item)
    }

    func handleOnSelect(item: MacroSplitOptionModel) {
        // Navigate to edit screen (same as swipe-left edit action)
        path.append(.macroEditorEdit(item))
    }

    func handleOnEdit(item: MacroSplitOptionModel) {
        // Navigate to edit screen
        path.append(.macroEditorEdit(item))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header: Name with selected indicator
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                if item.isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(palette.selection)
                        .font(.caption)
                }

                Spacer()
            }

            // Macro color bands
            GeometryReader { geo in
                let total = item.protein + item.carbs + item.fats
                let availableWidth = geo.size.width - 6

                HStack(spacing: 2) {
                    macroSegment(
                        color: palette.macroProtein,
                        value: item.protein,
                        total: total,
                        availableWidth: availableWidth
                    )

                    macroSegment(
                        color: palette.macroCarbs,
                        value: item.carbs,
                        total: total,
                        availableWidth: availableWidth
                    )

                    macroSegment(
                        color: palette.macroFat,
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
                    color: palette.macroProtein,
                    text: "protein \(item.protein)%",
                    alignment: .leading
                )
                macroDetail(
                    icon: "leaf.fill",
                    color: palette.macroCarbs,
                    text: "carbs \(item.carbs)%",
                    alignment: .center
                )
                macroDetail(
                    icon: "drop.fill",
                    color: palette.macroFat,
                    text: "fats \(item.fats)%",
                    alignment: .trailing
                )
            }
            .font(.subheadline)
            .foregroundStyle(palette.textSecondary)
        }
        .padding(16)
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.isSelected ? palette.selection.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle()) // Make the whole card tappable
        .onTapGesture {
            handleOnSelect(item: item)
        }

        // Swipe actions
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                handleOnEdit(item: item)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
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
    private func macroDetail(icon: String, color: Color, text: String, alignment: Alignment = .leading) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .font(.subheadline)
        .foregroundStyle(palette.textSecondary)
        .frame(maxWidth: .infinity, alignment: alignment)
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
            ordinal: 1,
            isSelected: true
        ),
        path: .constant([]),
        selectedMacroId: .constant(FactoryMacroSplits.Id.balanced)
    )
    .environment(MacroSplitOptionsModelCollection())
}
