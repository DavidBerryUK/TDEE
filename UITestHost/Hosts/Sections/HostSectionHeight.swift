//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSectionHeight: View {
    @State private var model = ProfileInputViewModel()
    
    var body: some View {
        TestHostContainer(
            title: "Section Height",
            instructions: "Section Height Host",
            content: { SectionHeight(model: model) },
            valueView:{    Text("height: \(model.height) cm")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSectionHeight()
    }
}
