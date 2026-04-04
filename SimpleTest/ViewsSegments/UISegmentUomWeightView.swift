//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentUomWeightView: View {
    
    @Binding var option: enumOptionWeight
    
    var body: some View {
        Picker("Weight", selection: $option) {
            ForEach(enumOptionWeight.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: enumOptionWeight = enumOptionWeight.kilograms
    UISegmentUomWeightView(option: $option)
}
