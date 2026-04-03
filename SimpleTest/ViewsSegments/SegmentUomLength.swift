//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentUomLength: View {
    
    @Binding var option: enumOptionLength
    
    var body: some View {
        Picker("Height Unit Of Measure", selection: $option) {
            Text("Cm").tag(enumOptionLength.centimeters)
            Text("Inches").tag(enumOptionLength.inches)
            Text("Feet & Inches").tag(enumOptionLength.feetAndInches)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: enumOptionLength = enumOptionLength.centimeters
    SegmentUomLength(option: $option)
}
