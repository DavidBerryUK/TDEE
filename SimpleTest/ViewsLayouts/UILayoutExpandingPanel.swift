//
//  UILayoutExpandingPanel.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

/// A panel that expands and collapses with animation.
struct UILayoutExpandingPanel<HeaderView: View, ContentView: View>: View {

    /// Binding controlling whether the panel is open
    @Binding var isOpen: Bool

    /// The header view displayed when the panel is collapsed or expanded
    let headerView: () -> HeaderView
    /// The content view displayed when the panel is open
    let contentView: () -> ContentView

    // MARK: - Animations

    private let expandAnimation = Animation.spring(
        response: 0.45,
        dampingFraction: 0.85
    )

    private let collapseAnimation = Animation.easeInOut(duration: 0.2)

    // MARK: - Init

    /// Creates a new expanding panel.
    /// - Parameters:
    ///   - isOpen: Binding controlling panel state
    ///   - header: View builder for the header
    ///   - content: View builder for the content
    init(
        isOpen: Binding<Bool>,
        @ViewBuilder header: @escaping () -> HeaderView,
        @ViewBuilder content: @escaping () -> ContentView
    ) {
        self._isOpen = isOpen
        self.headerView = header
        self.contentView = content
    }

    var body: some View {
        VStack(spacing: 0) {

            headerView()

            if isOpen {
                contentView()
                    .frame(maxHeight: .infinity)
                    .clipped()
            }
        }
        .accessibilityElement(children: .contain)
    }
}
