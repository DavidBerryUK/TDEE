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
            UIWheelPickerMacroMixView(macroSplit: macroMix)
        }
        .accessibilityElement(children: .contain)
    }
}

//#Preview {
//    @Previewable @State var macroMix = MacroSplitViewModel()
//    SectionEditorMacroMix(macroMix: macroMix)
//}
