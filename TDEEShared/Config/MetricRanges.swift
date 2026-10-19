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

    /// Weight in kilograms, inclusive (20 through 300). Shared by the Classic wheel picker and the New
    /// text entry so the accepted range lives in one place — story 023, input #4 / Decision 15.
    ///
    /// 20 kg (≈44 lb) rejects accidental low entries without excluding any 16–99 adult; 300 kg sits
    /// just above the Classic's ~260 kg stones cap, so no reachable Classic value becomes invalid.
    static let weight: ClosedRange<Double> = 20...300
}
