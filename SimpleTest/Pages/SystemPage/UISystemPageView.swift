//
//  SystemPage.swift
//  SimpleTest
//
//  Created by David Berry on 21/04/2026.
//
import SwiftUI

struct UISystemPageView: View {
    @Binding var path: [EnumAppRoute]

    var body: some View {
        List {
            Section("Navigation") {
                Button("Maintain Macro Config") { path.append(.maintainMacroConfig) }
                    .accessibilityLabel("Open macro configuration settings")
                    .accessibilityValue("Navigate to macro configuration")
                Button("Theme") { path.append(.theme) }
                    .accessibilityLabel("Change application theme")
                    .accessibilityValue("Navigate to theme settings")
                Button("About") { path.append(.about) }
                    .accessibilityLabel("View about information")
                    .accessibilityValue("Navigate to about page")
            }
        }
        .navigationTitle("System")
    }
}
