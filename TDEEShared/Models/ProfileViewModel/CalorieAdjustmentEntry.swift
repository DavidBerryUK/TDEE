//
//  CalorieAdjustmentEntry.swift
//  TDEEShared
//
//  Created by David Berry on 20/10/2026.
//

import Foundation

/// A pure validator for the New calorie-adjustment entry (story 023, input #11).
///
/// Maps the user's single field text to a status and, when the entry is complete and in range, the
/// adjustment in **kcal/day** — the model's single source of truth (`model.calorieAdjustment`, a
/// `Double`). It is deliberately free of any view or state so it can be unit-tested; the view drives it
/// and commits the resulting value to the model only when the status is `.ok`.
///
/// Entry is **integer** this pass (`.numberPad`), matching the Classic slider's whole-kcal granularity —
/// a free integer 0–1000 (the slider's 25-step was a slider affordance, not a value cap). The accepted
/// range is `MetricRanges.calorieAdjustment` — the one authority the entry and the Classic's
/// `CalorieAdjustmentConstants` share.
///
/// Unlike the personal inputs (age / weight / height / body fat), calorie adjustment carries **no
/// results gate**: it is not in `isValid` / `hasError`, and `adjustCalories` clamps to a non-negative
/// result. So this validator drives only the entry's reject-and-nag — there is no `isXValid` /
/// `validateForCalculation()` pair to keep in sync (Decision 14's caveat: the range lives in one place,
/// but nothing gates on it).
struct CalorieAdjustmentEntry {

    /// The outcome of validating a field entry.
    enum Status: Equatable {
        /// A complete, in-range entry — carries the adjustment in kcal/day to commit.
        case ok(calories: Double)
        /// No digits entered yet; the model's last valid value stands.
        case empty
        /// Digits entered but outside the accepted range.
        case outOfRange
        /// Digits present but not a valid whole number.
        case unparseable

        /// The kcal/day value when the status is `.ok`, else `nil`.
        var calories: Double? {
            if case let .ok(value) = self { return value }
            return nil
        }
    }

    /// The accepted calorie adjustment in kcal/day, shared with the Classic control.
    static var range: ClosedRange<Double> { MetricRanges.calorieAdjustment }

    /// Validate the field text. Returns `.ok(calories:)` only when the entry is complete and inside
    /// `range`; the view commits then.
    static func validate(_ text: String) -> Status {
        switch parse(text) {
        case .empty:
            return .empty
        case .invalid:
            return .unparseable
        case .value(let number):
            let kcal = Double(number)
            return range.contains(kcal) ? .ok(calories: kcal) : .outOfRange
        }
    }

    // MARK: - Parsing

    /// A parsed field: empty (no digits), a non-integer entry, or a whole number ≥ 0.
    private enum Parsed: Equatable {
        case empty
        case invalid
        case value(Int)

        var value: Int? {
            if case let .value(n) = self { return n }
            return nil
        }
    }

    /// Trim and classify a field. The `.numberPad` keyboard prevents negatives and non-integers, but the
    /// validator stays defensive — a negative is `.invalid` (0 is the floor, so there is no in-range
    /// "below" case to reject-and-nag).
    private static func parse(_ raw: String) -> Parsed {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .empty }
        guard let number = Int(trimmed), number >= 0 else { return .invalid }
        return .value(number)
    }
}
