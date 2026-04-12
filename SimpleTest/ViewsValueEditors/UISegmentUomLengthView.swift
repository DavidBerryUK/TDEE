//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentUomLengthView: View {
    
    @Binding var option: enumOptionLength
    
    var body: some View {
        Picker("Length", selection: $option) {
            ForEach(enumOptionLength.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: enumOptionLength = enumOptionLength.centimeters
    UISegmentUomLengthView(option: $option)
}
