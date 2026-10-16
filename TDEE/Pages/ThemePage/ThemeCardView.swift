//
//  ThemeCardView.swift
//  TDEE
//

import SwiftUI

/// A selectable card previewing a theme in its own colours for the current colour scheme.
struct ThemeCardView: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.palette) private var palette

    var body: some View {
        let preview = theme.palette(for: colorScheme)

        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                swatches(preview)

                HStack {
                    Text(theme.name)
                        .font(.headline)
                        .foregroundStyle(preview.text)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(preview.primary)
                    }
                }

                Text(theme.description)
                    .font(.caption)
                    .foregroundStyle(preview.textSecondary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(preview.background, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? palette.primary : preview.border, lineWidth: isSelected ? 3 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(theme.name) theme")
        .accessibilityValue(isSelected ? "Selected" : "")
        .accessibilityHint(theme.description)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func swatches(_ preview: ColorPalette) -> some View {
        HStack(spacing: 0) {
            ForEach(Array([preview.primary, preview.secondary, preview.surface,
                           preview.macroProtein, preview.macroCarbs, preview.macroFat].enumerated()),
                    id: \.offset) { _, color in
                color
            }
        }
        .frame(height: 24)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6).strokeBorder(preview.border, lineWidth: 1)
        }
    }
}

#Preview {
    ThemeCardView(theme: DefaultThemes.amethyst, isSelected: true) {}
        .padding()
}
