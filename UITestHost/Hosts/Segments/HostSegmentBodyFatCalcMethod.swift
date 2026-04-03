//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSegmentBodyFatCalcMethod: View {
    @State private var option: enumBodyFatOption = enumBodyFatOption.estimate
    
    var body: some View {
        TestHostContainer(
            title: "Segment - Bodyfat Calculation Method",
            instructions: "Use the select below to select a calculation method. This is a test host for the SegmentBodyFatCalcMethodView control."
        ) {
            VStack {
                SegmentBodyFatCalcMethodView(option: $option)
                Text("Method: \(option.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HostSegmentBodyFatCalcMethod()
    }
}
