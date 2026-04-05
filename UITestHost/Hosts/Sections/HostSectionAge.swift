//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSectionAge: View {
    @State private var model = ProfileInputViewModel()
    
    var body: some View {
        TestHostContainer(
            title: "Section Age",
            instructions: "Section Age Host",
            content: { SectionAge(model: model) },
            valueView:{    Text("age: \(model.age)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSectionAge()
    }
}
