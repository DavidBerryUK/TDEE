//
//  SystemPage.swift
//  SimpleTest
//
//  Created by David Berry on 21/04/2026.
//
import SwiftUI

struct SystemPage: View {
    @Binding var path: [EnumAppRoute]
    
    var body: some View {
        List {
            Section("Navigation") {
                Button("Maintain Macro Config") { path.append(.maintainMacroConfig) }
                Button("Theme") { path.append(.theme) }
                Button("About") { path.append(.about) }
            }
        }
        .navigationTitle("System")
    }
}
