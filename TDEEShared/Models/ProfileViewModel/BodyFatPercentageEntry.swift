//
//  BodyFatPercentageEntry.swift
//  TDEEShared
//
//  Created by David Berry on 20/10/2026.
//

import Foundation

/// A pure validator for the New body-fat-percentage entry (story 023, input #7).
///
/// Maps the user's single field text to a status and, when the entry is complete and in range, the
/// percentage as a **`Double` rounded to one decimal place** — the model's single source of truth.
/// It is deliberately free of any view or state so it can be unit-tested; the view drives it and
/// commits the resulting value to `model.bodyFatPercentage` only when the status is `.ok`.
///
/// This is the story's first **decimal** entry (Decision 20): the field is a `.decimalPad`, so —
/// unlike the integer weight / height entries (Decision 16) — it parses a decimal and rounds to one
/// place, matching the Classic's integer + decimal wheels (`value = integer + decimal / 10`). The
/// accepted range is `MetricRanges.bodyFatPercentage` — the one authority the Classic and New
/// controls share (Decision 21).
struct BodyFatPercentageEntry {

    /// The outcome of validating a field entry.
    enum Status: Equatable {
        /// A complete, in-range entry — carries the percentage (1 dp) to commit.
        case ok(value: Double)
        /// No digits entered yet; the model's last valid value stands.
        case empty
        /// Digits entered but outside the accepted range.
        case outOfRange
        /// Digits present but not a valid decimal number.
        case unparseable

        /// The percentage value when the status is `.ok`, else `nil`.
        var value: Double? {
            if case let .ok(v) = self { return v }
            return nil
        }
    }

    /// The accepted body fat percentage, shared with the Classic control.
    static var range: ClosedRange<Double> { MetricRanges.bodyFatPercentage }

    /// The number of decimal places the entry keeps, matching the Classic's integer + decimal wheels.
    static let decimalPlaces = 1

    /// Validate the field text. Returns `.ok(value:)` only when the entry is complete and inside
    /// `range`; the view commits the 1-dp value then.
    static func validate(_ text: String) -> Status {
        switch parse(text) {
        case .empty:
            return .empty
        case .invalid:
            return .unparseable
        case .value(let number):
            // Round to 1 dp so the stored value matches the Classic's granularity (Decision 20).
            let rounded = roundTo(number, decimalPlaces)
            return range.contains(rounded) ? .ok(value: rounded) : .outOfRange
        }
    }

    // MARK: - Rounding

    /// Round `value` to `places` decimal places (half away from zero).
    private static func roundTo(_ value: Double, _ places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (value * factor).rounded() / factor
    }

    // MARK: - Parsing

    /// A parsed field: empty (no digits), a non-decimal entry, or a number ≥ 0.
    private enum Parsed: Equatable {
        case empty
        case invalid
        case value(Double)

        var value: Double? {
            if case let .value(v) = self { return v }
            return nil
        }
    }

    /// Trim and classify a field. `.decimalPad` yields digits and a decimal point; a non-decimal or a
    /// negative is `.invalid` — the keyboard prevents both, but the validator stays defensive.
    private static func parse(_ raw: String) -> Parsed {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .empty }
        guard let number = Double(trimmed), number >= 0 else { return .invalid }
        return .value(number)
    }
}
