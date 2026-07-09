//
//  Constants.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

enum Spacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
}

struct AnimationParams {
    /// Default spring animation parameters for UI interactions
    static let springDefault = Animation.spring(response: 0.3, dampingFraction: 0.8)

    /// Fast animation duration for UI transitions
    static let fastDuration = Animation.easeInOut(duration: 0.3)

    /// Spring response value for expanding panels (0.45)
    static let expandingPanelResponse: Double = 0.45

    /// Spring damping fraction for expanding panels (0.85)
    static let expandingPanelDampingFraction: Double = 0.85
}
