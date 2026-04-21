//
//  ContentView.swift
//  TempProteinFatsCarbsMixer
//
//  Created by David Berry on 13/04/2026.
//

import SwiftUI
import SwiftData

struct MacroMixerPage: View {
    
    
    @Environment(MacroSplitViewModelCollection.self)
    var collection
    
    @State private var path: [String] = []
    
    //
    // this will be used to add new items to the collection
    //
    func handleOnSaveNew(item: MacroSplitViewModel) {
        collection.add(item)
    }
        
    var body: some View {
        
        
        NavigationStack(path: $path) {
            VStack {
                MacroOptionsListView()
            }
            .navigationTitle("Macros")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append("create")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "create":
                    MacroEditView(
                        item: nil,
                        onSave: { updated in handleOnSaveNew(item: updated) }
                    )

                default:
                    EmptyView()
                }
            }
        }
    }
}

