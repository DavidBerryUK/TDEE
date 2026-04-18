//
//  HostPickerAge.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct HostMacroMixer: View {
    private var model = ProfileViewModel()
    
    var body: some View {
        TestHostContainer(
            title: "Macro Mixer Test",
            instructions: "This is a test host for the UISliderMacroMixView control.",
            content: { UISliderMacroMixView(model: model) },
            valueView: { EmptyView()}
        )
    
    }
}

#Preview {
    HostMacroMixer()
}
