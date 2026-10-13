//
//  IconModel.swift
//  SimpleTest
//
//  Created by David Berry on 07/04/2026.
//

import SwiftUI

/// Represents an icon with its visual and label properties.
struct IconModel {
    /// The icon identifier
    let id: Icon
    /// The display label for the icon
    let label: String
    /// The solid symbol name
    let symbolSolid: String
    /// The outlined symbol name
    let symbolOutlined: String
    /// The color to use for the icon
    let color: Color
}
