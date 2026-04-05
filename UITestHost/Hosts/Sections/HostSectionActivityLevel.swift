//
//  HostPickerWeight.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostSectionActivityLevel: View {
    @State private var model = ProfileInputViewModel()
    
    var body: some View {
        TestHostContainer(
            title: "Section Activity Level",
            instructions: "Section Activity Level Host",
            content: { SectionActivityLevel(model: model) },
            valueView:{    Text("activity level: \(model.activityLevel.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
    }
}

#Preview {
    NavigationStack {
        HostSectionActivityLevel()
    }
}
