//
//  AboutPage.swift
//  TDEE
//
//  Created by David Berry on 21/04/2026.
//
import SwiftUI

struct AboutPage: View {
    @Environment(\.palette) private var palette
    var body: some View {
        VStack(spacing: 12) {
            Text("About This App")
                .font(.title2).bold()
            Text("Version 1.0")
                .foregroundStyle(palette.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.background)
        .navigationTitle("About")
    }
}
