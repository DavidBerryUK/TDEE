//
//  WeightEntry.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import Foundation

/// A pure validator for the New weight entry (story 023, inputs #3 / #4).
///
/// Maps a unit of measure + the user's field text to a status and, when the entry is complete and in
/// range, the weight in **kilograms** — the model's single source of truth. It is deliberately free of
/// any view or state so it can be unit-tested; the view drives it and commits the resulting kg to
/// `model.weight` only when the status is `.ok`.
///
/// Entry is integer this pass (Decision 16): every field is a whole number, matching the Classic's
/// integer wheels. kg / pounds read one field; stones & pounds read two (stones, then a pounds
/// remainder of 0–13). The accepted range is `MetricRanges.weight` — the one authority the Classic and
/// New controls share (Decisions 13 & 15).
struct WeightEntry {

    /// The outcome of validating a field entry.
    enum Status: Equatable {
        /// A complete, in-range entry — carries the weight in kilograms to commit.
        case ok(kg: Double)
        /// No digits entered yet; the model's last valid value stands.
        case empty
        /// Digits entered but outside the accepted range, or a stones pounds-remainder of 14 or more
        /// (reject-and-nag, Decision 12).
        case outOfRange
        /// Digits present but not a valid whole number.
        case unparseable

        /// The kg value when the status is `.ok`, else `nil`.
        var kg: Double? {
            if case let .ok(value) = self { return value }
            return nil
        }
    }

    /// The accepted weight in kilograms, shared with the Classic control.
    static var range: ClosedRange<Double> { MetricRanges.weight }

    /// Validate the field text for `unit`.
    ///
    /// - For `.kilograms` / `.pounds`, `fields` is a single string.
    /// - For `.stonesAndPounds`, `fields` is `[stones, pounds]` — the remainder, 0–13.
    ///
    /// Returns `.ok(kg:)` only when the entry is complete and inside `range`; the view commits then.
    static func validate(unit: OptionWeight, fields: [String]) -> Status {
        switch unit {
        case .kilograms, .pounds:
            return single(unit: unit, text: fields.first ?? "")
        case .stonesAndPounds:
            return stonesPounds(stonesText: fields.first ?? "", poundsText: fields.dropFirst().first ?? "")
        }
    }

    // MARK: - Single field (kg / pounds)

    /// One integer field, converted to kg and checked against the shared range.
    private static func single(unit: OptionWeight, text: String) -> Status {
        switch parse(text) {
        case .empty:
            return .empty
        case .invalid:
            return .unparseable
        case .value(let number):
            let kg: Double
            switch unit {
            case .kilograms:
                kg = Double(number)
            case .pounds:
                kg = WeightConvertor.toKilograms(pounds: number)
            case .stonesAndPounds:
                // A single field is not a complete stones entry.
                return .unparseable
            }
            return range.contains(kg) ? .ok(kg: kg) : .outOfRange
        }
    }

    // MARK: - Stones & pounds (two fields)

    /// Two integer fields: stones (0–40) and a pounds remainder (0–13), folded to kg via the shared
    /// converter and checked against the range.
    private static func stonesPounds(stonesText: String, poundsText: String) -> Status {
        let stones = parse(stonesText)
        let pounds = parse(poundsText)

        // No digits at all → not a complete entry.
        if stones == .empty && pounds == .empty { return .empty }
        // A non-numeric field is unparseable.
        if stones == .invalid || pounds == .invalid { return .unparseable }

        // An empty field counts as 0 (e.g. "11 st" with a blank pounds box reads as 11 st 0 lb).
        let stonesValue = stones.value ?? 0
        let poundsValue = pounds.value ?? 0

        // Decision 12: the pounds remainder is 0–13 — a 14+ entry is out of range and nags, rather
        // than being silently carried into the stones box.
        guard poundsValue <= 13 else { return .outOfRange }
        // Stones itself is capped at 40 (≈260 kg); heavier weights are entered in kg / lb.
        guard stonesValue <= 40 else { return .outOfRange }

        let kg = WeightConvertor.toKilograms(stones: stonesValue, pounds: poundsValue)
        return range.contains(kg) ? .ok(kg: kg) : .outOfRange
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
