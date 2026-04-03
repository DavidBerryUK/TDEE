//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSegmentUomLength: View {
    @State private var option: enumOptionLength = enumOptionLength.centimeters // example starting value
    
    var body: some View {
        TestHostContainer(
            title:"Unit Of Measure - Length",
            instructions: "Use the picker below to select a unit of length. This is a test host for SegmentUomLength control.",
            content: {SegmentUomLengthView(option: $option)},
            valueView:{
                Text("Unit Of Measure: \(option.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSegmentUomLength()
    }
}
