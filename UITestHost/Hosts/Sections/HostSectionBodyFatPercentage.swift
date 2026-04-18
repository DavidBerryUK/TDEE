//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSectionBodyFatPercentage: View {
    @State private var model = ProfileViewModel()
    
    var body: some View {
        TestHostContainer(
            title: "Section Body Fat Level",
            instructions: "Section Body Fat Host",
            content: { SectionBodyFatPercentage(model: model) },
            valueView:{    Text("body fat: \(model.bodyFatPercentageMethod.displayName) \(model.bodyFatPercentage)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSectionBodyFatPercentage()
    }
}
