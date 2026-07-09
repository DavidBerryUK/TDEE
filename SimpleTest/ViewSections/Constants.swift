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
    static let springDefault = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let fastDuration = Animation.easeInOut(duration: 0.3)
}
