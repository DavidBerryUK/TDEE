//
//  MetricRanges.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import Foundation

/// Shared numeric bounds for profile inputs.
///
/// Keeping the bounds here — rather than hard-coded in each control — lets an input's Classic and New
/// controls agree on the accepted range. Story 023, input #2 (Age) starts this; height, weight and
/// body fat can add their bounds here as they're converted.
enum MetricRanges {

    /// Age in years, inclusive (16 through 99). Shared by the Classic wheel picker and the New text
    /// input so the range lives in one place.
    static let age: ClosedRange<Int> = 16...99
}
