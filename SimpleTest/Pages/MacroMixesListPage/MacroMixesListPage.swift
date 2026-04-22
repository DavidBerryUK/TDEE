////
////  ContentView.swift
////  TempProteinFatsCarbsMixer
////
////  Created by David Berry on 13/04/2026.
////
//
//import SwiftUI
//import SwiftData
//
//struct MacroMixesListPage: View {
//    
//    
//    @Environment(MacroSplitViewModelCollection.self)
//    var collection
//    
//    @State public var path: [EnumAppRoute]
//    
//    //
//    // this will be used to add new items to the collection
//    //
//    func handleOnSaveNew(item: MacroSplitViewModel) {
//        collection.add(item)
//    }
//        
//    var body: some View {
//        
//        
//        NavigationStack(path: $path) {
//            VStack {
//                MacroOptionsListViewPage( path: path)
//            }
//            
//
//            .navigationDestination(for: String.self) { value in
//                switch value {
//                case "create":
//                    MacroEditViewPage(
//                        item: nil,
//                        onSave: { updated in handleOnSaveNew(item: updated) }
//                    )
//
//                default:
//                    EmptyView()
//                }
//            }
////        }a
//    }
//}
//
