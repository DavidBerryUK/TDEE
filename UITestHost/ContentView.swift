//
//  ContentView.swift
//  UITestHost
//
//  Created by David Berry on 03/04/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var profile = ProfileViewModel()
    
    var body: some View {
        
        TestHostCatalogView()
        
    }
}

#Preview {
    ContentView()
}
