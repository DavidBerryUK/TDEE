//
//  WatchInputViews.swift
//  TDEE Watch
//
//

import SwiftUI

/// A titled screen holding one wheel picker.
internal struct WheelScreen<Content: View>: View {
        let title: String
        let showChangeUnit: Bool 
        @ViewBuilder let content: Content

        var body: some View {
            VStack{
                content
                    .pickerStyle(.wheel)
                // The screen title already names the value; VoiceOver still reads each picker's own label
                    .labelsHidden()
                    .navigationTitle(title)
                if showChangeUnit {
                    Button {
                    } label: {
                        Text("Change Unit")
                    }.controlSize(.mini)
                }
            }
    }
}
