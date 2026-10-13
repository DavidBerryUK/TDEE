//
//  MacroOptionsListInstructions.swift
//  TempProteinFatsCarbsMixer
//
//  Created by David Berry on 19/04/2026.
//
import SwiftUI

struct MacroOptionsListInstructions: View {
    // Floating footer with usage instructions

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundStyle(.blue)

                Text("Tap a mix to select or edit")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            HStack {
                Image(systemName: "swipe.left")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text("Swipe left to delete")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

#Preview {
    MacroOptionsListInstructions()
}
