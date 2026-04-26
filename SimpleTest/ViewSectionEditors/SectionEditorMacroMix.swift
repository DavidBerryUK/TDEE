//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorMacroMix: View {
    
    @Environment(MacroSplitOptionsModelCollection.self) private var collection
    @Bindable var macroMix: MacroSplitViewModel
    
    var body: some View {
        
        var selectedOption: MacroSplitOptionModel? {
            collection.items.first { $0.id == macroMix.selectedMacroId }
        }
        
        VStack {
            Text("selected macro: \(selectedOption?.name ?? "")")
            UIWheelPickerMacroMixView(macroSplit: macroMix)
        }
    }
}

//#Preview {
//    @Previewable @State var macroMix = MacroSplitViewModel()
//    SectionEditorMacroMix(macroMix: macroMix)
//}
