//
//  MacroOptionsListInstructions.swift
//  TempProteinFatsCarbsMixer
//
//  Created by David Berry on 19/04/2026.
//
import SwiftUI

struct MacroOptionsListInstructions : View {
    // Floating footer
    
    var body: some View {
        
        HStack {
            Text("Tap to edit • Swipe left to delete")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 34,
                style: .continuous
            )
            .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, y: 3)
        .padding(.horizontal, 24)
        .padding(.bottom, -8)
        
    }
}
