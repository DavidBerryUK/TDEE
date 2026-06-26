//
//  UIContainerExpanderViewExtension.swift
//  QuickExpanderBox
//
//  Created by David Berry on 21/06/2026.
//
import SwiftUI

/// A custom view modifier to apply a spring animation for container expansion.
struct AnimateUIAccordion: ViewModifier {
    @Binding var isExpandedArray: [Bool]
    
    func body(content: Content) -> some View {
        content.animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpandedArray)
    }
}

extension View {
    /// Applies a spring animation for container expansion.
    func animateUIAccordian(isExpandedArray: Binding<[Bool]>) -> some View {
        modifier(AnimateUIAccordion(isExpandedArray: isExpandedArray))
    }
}
