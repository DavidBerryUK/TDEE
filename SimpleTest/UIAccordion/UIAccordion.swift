//
//  UIAccordion.swift
//  QuickExpanderBox
//
//  Created by David Berry on 21/06/2026.
//

import SwiftUI

/// A custom accordion view that can expand and collapse content.
///
/// This struct provides an accordion-like component with a toggleable expansion state.
/// The content within the accordion is revealed or hidden based on the `isExpanded` binding.
struct UIAccordion<Content: View>: View {
    @Binding var isExpanded: Bool
    let content: () -> Content
    
    init(isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isExpanded = isExpanded
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                content()
                    .frame(minHeight: 50)
                    .transition(.opacity)
            }
            // Rectangle().fill(Color.gray).frame(height: 1)
        }
    }
}
