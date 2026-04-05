//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSectionWeight: View {
    @State private var model = ProfileInputViewModel()
    
    var body: some View {
        TestHostContainer(
            title: "Section Weight",
            instructions: "Section Weight Host",
            content: { SectionWeight(model: model) },
            valueView:{    Text("weight: \(model.weight) kg")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSectionWeight()
    }
}
