//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSegmentMacroSplitMethod: View {
    @State private var option: enumMacroSplitMethod = enumMacroSplitMethod.ketogenic
    
    var body: some View {
        TestHostContainer(
            title: "Segment - Macro Split Method",
            instructions: "Use the select below to select a Macro Split Method. This is a test host for the UISegmentMacroSplitMethodView control.",
            content:{UISegmentMacroSplitMethodView(option: $option)},
            valueView:{
                Text("Gender: \(option.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSegmentMacroSplitMethod()
    }
}
