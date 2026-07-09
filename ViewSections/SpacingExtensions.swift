import SwiftUI
import SimpleTest

// MARK: - Spacing Constants & Extensions

/**
 * Provides clean, reusable access to application-defined spacing constants,
 * replacing hardcoded CGFloat values (8.0, 12.0, 16.0).
 */
struct AppSpacing {
    static let small: Double = 8.0
    static let medium: Double = 12.0
    static let large: Double = 16.0
}

// MARK: - View Modifiers & Extensions

/**
 * A reusable modifier to apply spacing derived from AppSpacing constants.
 * This is the primary mechanism for consistent padding application.
 */
struct SpacingModifier: ViewModifier {
    let constant: Double
    let dimension: Dimension

    enum Dimension {
        case horizontal
        case vertical
        case all
    }

    func bodyWillSet(_ values: SwiftUI.PaddingValues) -> some View {
        // This block is just for conceptual clarity in the modifier definition;
        // actual modification happens in the final view's context.
        self
    }

    func body(content: Content) -> some View {
        switch dimension {
        case .all: return content.padding(.all, CGFloat(constant))
        case .horizontal: return content.padding(.horizontal, CGFloat(constant))
        case .vertical: return content.padding(.vertical, CGFloat(constant))
        }
    }
}

extension View {
    /// Applies consistent vertical padding using AppSpacing constants.
    func paddedVertical(_ spacing: Double) -> some View {
        self.modifier(SpacingModifier(constant: spacing, dimension: .vertical))
    }

    /// Applies consistent horizontal padding using AppSpacing constants.
    func paddedHorizontal(_ spacing: Double) -> some View {
        self.modifier(SpacingModifier(constant: spacing, dimension: .horizontal))
    }

    /// Applies consistent all-around padding using AppSpacing constants.
    func paddedAll(_ spacing: Double) -> some View {
        self.modifier(SpacingModifier(constant: spacing, dimension: .all))
    }
}