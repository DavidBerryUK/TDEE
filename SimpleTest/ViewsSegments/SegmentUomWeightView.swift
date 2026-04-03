//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentUomWeightView: View {
    
    @Binding var option: enumOptionWeight
    
    var body: some View {
        Picker("Weight Unit Of Measure", selection: $option) {
            Text("Kg").tag(enumOptionWeight.kilograms)
            Text("Pounds").tag(enumOptionWeight.pounds)
            Text("Stones & Pounds").tag(enumOptionWeight.stonesAndPounds)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: enumOptionWeight = enumOptionWeight.kilograms
    SegmentUomWeightView(option: $option)
}
