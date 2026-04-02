//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSegmentUomWeight: View {
    @State private var option: AppEnums.enumOptionWeight = AppEnums.enumOptionWeight.pounds // example starting value
    
    var body: some View {
        TestHostContainer(
            title: "Unit Of Measure - Weight",
            instructions: "Use the picker below to select a unit of weigh. This is a test host for the SegmentUomWeightView control."
        ) {
            VStack {
                SegmentUomWeightView(option: $option)
                Text("Unit Of Measure: \(option)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HostSegmentUomWeight()
    }
}
