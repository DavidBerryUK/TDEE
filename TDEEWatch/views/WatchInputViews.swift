//
//  WatchInputViews.swift
//  TDEE Watch
//
//

import SwiftUI

/// A titled screen holding one wheel picker.
internal struct WheelScreen<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        content
            .pickerStyle(.wheel)
            .navigationTitle(title)
            .accessibilityLabel(title)
    }
}
