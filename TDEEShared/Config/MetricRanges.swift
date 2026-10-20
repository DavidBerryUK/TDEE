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
/// controls agree on the accepted range. Story 023, input #2 (Age) started this; height (#5/#6) and
/// weight (#3/#4) follow, body fat can add its bounds as it's converted.
enum MetricRanges {

    /// Age in years, inclusive (16 through 99). Shared by the Classic wheel picker and the New text
    /// input so the range lives in one place.
    static let age: ClosedRange<Int> = 16...99

    /// Height in centimeters, inclusive (100 through 272). Shared by the Classic wheel picker and the
    /// New text entry so the accepted range lives in one place — story 023, input #6.
    ///
    /// 100 cm (≈3 ft 3 in) rejects accidental low entries without excluding any 16–99 adult; 272 cm
    /// matches the Classic wheels' reach (~8 ft 11 in), so no reachable Classic value becomes invalid.
    static let height: ClosedRange<Double> = 100...272

    /// Weight in kilograms, inclusive (20 through 300). Shared by the Classic wheel picker and the New
    /// text entry so the accepted range lives in one place — story 023, input #4 / Decision 15.
    ///
    /// 20 kg (≈44 lb) rejects accidental low entries without excluding any 16–99 adult; 300 kg sits
    /// just above the Classic's ~260 kg stones cap, so no reachable Classic value becomes invalid.
    static let weight: ClosedRange<Double> = 20...300

    /// Body fat percentage, inclusive (5 through 50). Shared by the Classic wheel picker and the New
    /// decimal entry so the accepted range lives in one place — story 023, input #7 / Decision 21.
    ///
    /// 5% (≈ lean-athlete floor) and 50% (≈ upper realistic range) bound a physiologically realistic
    /// adult range. Applied only under the `.manualEntry` method — Omit / Estimate carry no % value to
    /// validate.
    static let bodyFatPercentage: ClosedRange<Double> = 5...50

    /// Calorie adjustment in kcal/day, inclusive (0 through 1000). Story 023, input #11.
    ///
    /// 0–1000 kcal/day matches the Classic slider's `CalorieAdjustmentConstants` reach, so no reachable
    /// Classic value becomes out-of-range. Unlike the personal inputs, calorie adjustment carries **no
    /// results gate** (it is not in `isValid` / `hasError`), so this authority drives only the New
    /// entry's reject-and-nag — the entry commits in-range kcal/day to the model, which is the single
    /// source of truth.
    static let calorieAdjustment: ClosedRange<Double> = 0...1000
}
