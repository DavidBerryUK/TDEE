//
//  WatchInputViews.swift
//  TDEE Watch
//
//

import SwiftUI

/// A titled screen holding one wheel picker.
///
/// When `showChangeUnit` is true a "Change Unit" control is shown; it is a
/// value-based `NavigationLink` (like the rows in `WatchMainView`) that pushes the
/// screen-supplied `changeUnitDestination`, so swiping back returns to this screen.
internal struct WheelScreen<Content: View, Destination: View>: View {
    let title: String
    let showChangeUnit: Bool
    let content: Content
    let changeUnitDestination: () -> Destination

    init(title: String,
         showChangeUnit: Bool,
         @ViewBuilder changeUnitDestination: @escaping () -> Destination = { EmptyView() },
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.showChangeUnit = showChangeUnit
        self.changeUnitDestination = changeUnitDestination
        self.content = content()
    }

    var body: some View {
        VStack {
            content
                .pickerStyle(.wheel)
            // The screen title already names the value; VoiceOver still reads each picker's own label
                .labelsHidden()
                .navigationTitle(title)
            if showChangeUnit {
                NavigationLink {
                    changeUnitDestination()
                } label: {
                    Text("Change Unit")
                }
                .controlSize(.mini)
            }
        }
    }
}
