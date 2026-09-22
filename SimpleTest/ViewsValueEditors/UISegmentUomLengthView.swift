//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentUomLengthView: View {

    @Binding var option: OptionLength

    var body: some View {
        Picker("Length", selection: $option) {
            ForEach(OptionLength.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("heightUnitSelector")
    }
}

#Preview {
    @Previewable @State var option: OptionLength = OptionLength.centimeters
    UISegmentUomLengthView(option: $option)
}
