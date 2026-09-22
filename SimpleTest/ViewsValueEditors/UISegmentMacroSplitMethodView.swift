//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentMacroSplitMethodView: View {

    @Binding var option: MacroSplitMethod

    var body: some View {
        Picker("Macro Split", selection: $option) {
            ForEach(MacroSplitMethod.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("macroSplitMethodSelector")
    }
}

#Preview {
    @Previewable @State var option: MacroSplitMethod = MacroSplitMethod.custom
    UISegmentMacroSplitMethodView(option: $option)
}
