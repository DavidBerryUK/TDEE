import SwiftUI

/// Centralized constants for predefined color styles, especially those requiring hardcoded alpha values.
struct ColorStyles {
    /// Standard opacity (0.85) used for primary feature elements or highlights (e.g., protein macro)
    static let macroProteinOpacity: Color = .red.opacity(0.85)

    /// Light opacity (0.5) used for info/error states
    static let infoErrorLightOpacity: Color = .blue.opacity(0.5)

    /// Low alpha (0.1) used for primary background fills indicating state changes
    static let primaryFillLowAlpha: Color = .red.opacity(0.1) // Used in MacroEditViewPage

    /// Low alpha (0.15) used for secondary background fills indicating state changes
    static let secondaryFillLowAlpha: Color = .red.opacity(0.15) // Used in MacroEditViewPage

    // Utility color for consistency, even if the number itself changes (e.g., specific grey shades).
    static var primaryTextDisabled: Color {
        Color(.placeholderText) // Assuming system standard access
    }
}