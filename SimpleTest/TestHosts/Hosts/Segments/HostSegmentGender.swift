//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSegmentGender: View {
    @State private var option: enumGender = enumGender.male
    
    var body: some View {
        TestHostContainer(
            title: "Segment - Gender",
            instructions: "Use the select below to select a Gender. This is a test host for the SegmentGenderView control."
        ) {
            VStack {
                SegmentGenderView(option: $option)
                Text("Gender: \(option)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HostSegmentGender()
    }
}
