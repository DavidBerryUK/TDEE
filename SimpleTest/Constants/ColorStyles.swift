import SwiftUI

/// Centralized constants for predefined color styles, especially those requiring hardcoded alpha values.
struct ColorStyles {
    // Standard opacity used for primary feature elements or highlights.
    static let macroProteinOpacity: Color = .red.opacity(0.85)
    static let infoErrorLightOpacity: Color = .blue.opacity(0.5)

    // Opacity frequently used for background fills when indicating a state change (e.g., selected vs deselected).
    static let primaryFillLowAlpha: Color = .red.opacity(0.1) // Used in MacroEditViewPage
    static let secondaryFillLowAlpha: Color = .red.opacity(0.15) // Used in MacroEditViewPage

    // Utility color for consistency, even if the number itself changes (e.g., specific grey shades).
    static var primaryTextDisabled: Color {
        Color(.placeholderText) // Assuming system standard access
    }
}