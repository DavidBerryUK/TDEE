//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentMacroSplitMethodView: View {

    @Binding var option: enumMacroSplitMethod

    var body: some View {
        Picker("Macro Split", selection: $option) {
            ForEach(enumMacroSplitMethod.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Macro split calculation method selector")
        .accessibilityValue("Current: \(option.displayName)")
    }
}

#Preview {
    @Previewable @State var option: enumMacroSplitMethod = enumMacroSplitMethod.custom
    UISegmentMacroSplitMethodView(option: $option)
}
