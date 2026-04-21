//
//  SimpleTestApp.swift
//  SimpleTest
//
//  Created by David Berry on 31/03/2026.
//

import SwiftUI

@main
struct SimpleTestApp: App {
    
    var macroSplitCollection = MacroSplitViewModelCollection(items: FactoryMacroSplits.get())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(macroSplitCollection)
        }
    }
}
