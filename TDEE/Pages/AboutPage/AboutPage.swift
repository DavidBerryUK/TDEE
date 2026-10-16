//
//  AboutPage.swift
//  TDEE
//
//  Created by David Berry on 21/04/2026.
//
import SwiftUI

struct AboutPage: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("About This App")
                .font(.title2).bold()
            Text("Version 1.0")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("About")
    }
}
