//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentUomWeightView: View {
    
    @Binding var option: AppEnums.enumOptionWeight
    
    var body: some View {
        Picker("Weight Unit Of Measure", selection: $option) {
            Text("Kg").tag(AppEnums.enumOptionWeight.kilograms)
            Text("Pounds").tag(AppEnums.enumOptionWeight.pounds)
            Text("Stones & Pounds").tag(AppEnums.enumOptionWeight.StonesAndPounds)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: AppEnums.enumOptionWeight = AppEnums.enumOptionWeight.kilograms
    SegmentUomWeightView(option: $option)
}
