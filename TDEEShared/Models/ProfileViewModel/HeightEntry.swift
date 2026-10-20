//
//  HeightEntry.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import Foundation

/// A pure validator for the New height entry (story 023, inputs #5 / #6).
///
/// Mirrors `WeightEntry`: maps a unit of measure + the user's field text to a status and, when the
/// entry is complete and in range, the height in **centimeters** — the model's single source of
/// truth. It is deliberately free of any view or state so it can be unit-tested; the view drives it
/// and commits the resulting cm to `model.height` only when the status is `.ok`.
///
/// Entry is integer this pass (`.numberPad`), matching the Classic's integer wheels. cm / inches read
/// one field; feet & inches read two (feet, then an inches remainder of 0–11). The accepted range is
/// `MetricRanges.height` — the one authority the Classic and New controls share (Decisions 13 & 15).
struct HeightEntry {

    /// The outcome of validating a field entry.
    enum Status: Equatable {
        /// A complete, in-range entry — carries the height in centimeters to commit.
        case ok(cm: Double)
        /// No digits entered yet; the model's last valid value stands.
        case empty
        /// Digits entered but outside the accepted range, or a feet inches-remainder of 12 or more
        /// (reject-and-nag, Decision 12).
        case outOfRange
        /// Digits present but not a valid whole number.
        case unparseable

        /// The cm value when the status is `.ok`, else `nil`.
        var cm: Double? {
            if case let .ok(value) = self { return value }
            return nil
        }
    }

    /// The accepted height in centimeters, shared with the Classic control.
    static var range: ClosedRange<Double> { MetricRanges.height }

    /// Validate the field text for `unit`.
    ///
    /// - For `.centimeters` / `.inches`, `fields` is a single string.
    /// - For `.feetAndInches`, `fields` is `[feet, inches]` — the remainder, 0–11.
    ///
    /// Returns `.ok(cm:)` only when the entry is complete and inside `range`; the view commits then.
    static func validate(unit: OptionLength, fields: [String]) -> Status {
        switch unit {
        case .centimeters, .inches:
            return single(unit: unit, text: fields.first ?? "")
        case .feetAndInches:
            return feetInches(feetText: fields.first ?? "", inchesText: fields.dropFirst().first ?? "")
        }
    }

    // MARK: - Single field (cm / inches)

    /// One integer field, converted to cm and checked against the shared range.
    private static func single(unit: OptionLength, text: String) -> Status {
        switch parse(text) {
        case .empty:
            return .empty
        case .invalid:
            return .unparseable
        case .value(let number):
            let cm: Double
            switch unit {
            case .centimeters:
                cm = Double(number)
            case .inches:
                cm = LengthConverter.toCentimeters(number)
            case .feetAndInches:
                // A single field is not a complete feet & inches entry.
                return .unparseable
            }
            return range.contains(cm) ? .ok(cm: cm) : .outOfRange
        }
    }

    // MARK: - Feet & inches (two fields)

    /// Two integer fields: feet and an inches remainder (0–11), folded to cm via the shared converter
    /// and checked against the range.
    private static func feetInches(feetText: String, inchesText: String) -> Status {
        let feet = parse(feetText)
        let inches = parse(inchesText)

        // No digits at all → not a complete entry.
        if feet == .empty && inches == .empty { return .empty }
        // A non-numeric field is unparseable.
        if feet == .invalid || inches == .invalid { return .unparseable }

        // An empty field counts as 0 (e.g. "5 ft" with a blank inches box reads as 5 ft 0 in).
        let feetValue = feet.value ?? 0
        let inchesValue = inches.value ?? 0

        // Decision 12 analog: the inches remainder is 0–11 — a 12+ entry is out of range and nags,
        // rather than being silently carried into the feet box. The cm range catches any feet value
        // beyond the ceiling, so no separate feet cap is needed.
        guard inchesValue <= 11 else { return .outOfRange }

        let cm = LengthConverter.toCentimeters(feet: feetValue, inches: inchesValue)
        return range.contains(cm) ? .ok(cm: cm) : .outOfRange
    }

    // MARK: - Parsing

    /// A parsed field: empty (no digits), a non-numeric entry, or a whole number ≥ 0.
    private enum Parsed: Equatable {
        case empty
        case invalid
        case value(Int)

        var value: Int? {
            if case let .value(n) = self { return n }
            return nil
        }
    }

    /// Trim and classify a field. Negatives and non-integers are `.invalid` — the `.numberPad`
    /// keyboard prevents both, but the validator stays defensive.
    private static func parse(_ raw: String) -> Parsed {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .empty }
        guard let number = Int(trimmed), number >= 0 else { return .invalid }
        return .value(number)
    }
}
