//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentUomWeightView: View {

    @Binding var option: OptionWeight

    var body: some View {
        Picker("Weight", selection: $option) {
            ForEach(OptionWeight.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Weight unit selector")
        .accessibilityValue("Current: \(option.displayName)")
    }
}

#Preview {
    @Previewable @State var option: OptionWeight = OptionWeight.kilograms
    UISegmentUomWeightView(option: $option)
}
