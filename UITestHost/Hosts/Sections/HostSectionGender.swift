//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSectionGender: View {
    @State private var model = ProfileViewModel()
    
    var body: some View {
        TestHostContainer(
            title: "Section Gender",
            instructions: "Section Gender Host",
            content: { SectionGender(model: model) },
            valueView:{    Text("gender: \(model.gender.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSectionGender()
    }
}
