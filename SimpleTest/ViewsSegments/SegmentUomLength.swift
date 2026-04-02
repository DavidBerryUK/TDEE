//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentUomLength: View {
    
    @Binding var option: AppEnums.enumOptionLength
    
    var body: some View {
        Picker("Height Unit Of Measure", selection: $option) {
            Text("Cm").tag(AppEnums.enumOptionLength.centimeters)
            Text("Inches").tag(AppEnums.enumOptionLength.inches)
            Text("Feet & Inches").tag(AppEnums.enumOptionLength.feetAndInches)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: AppEnums.enumOptionLength = AppEnums.enumOptionLength.centimeters
    SegmentUomLength(option: $option)
}
