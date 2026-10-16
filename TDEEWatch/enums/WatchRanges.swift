//
//  WatchRanges.swift
//  TDEE Watch
//
//

import SwiftUI

// Weight is stored in kg and height in cm. The watch edits those units directly.
// Ranges match the iPhone wheel pickers.

internal enum WatchRanges {
    static let age = Array(16...99)
    static let weightKg = Array(0...250)
    static let heightCm = Array(0...272)
    static let bodyFatInteger = Array(0...99)
    static let bodyFatDecimal = Array(0...9)
    /// Same limits as `CalorieAdjustmentConstants` on the iPhone (that file is iPhone-only).
    static let adjustment = Array(stride(from: 0, through: 1000, by: 25))
}
