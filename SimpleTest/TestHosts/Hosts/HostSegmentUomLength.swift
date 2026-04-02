//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSegmentUomLength: View {
    @State private var option: AppEnums.enumOptionLength = AppEnums.enumOptionLength.centimeters // example starting value
    
    var body: some View {
        TestHostContainer(
            title:"Unit Of Measure - Length",
            instructions: "Use the picker below to select a unit of length. This is a test host for SegmentUomLength control."
        ) {
            VStack {
                SegmentUomLength(option: $option)
                Text("Unit Of Measure: \(option)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HostSegmentUomLength()
    }
}
