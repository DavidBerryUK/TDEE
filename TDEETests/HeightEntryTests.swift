//
//  HeightEntryTests.swift
//  TDEETests
//
//  Story 023, inputs #5 / #6 — the pure HeightEntry validator, the MetricRanges.height gate, and the
//  two model gates that must agree on height (Decision 14 analog).
//

import Testing
@testable import TDEE
import Foundation

@Suite("HeightEntry Tests")
@MainActor
struct HeightEntryTests {

    // MARK: - Single field: centimeters

    @Test("A valid cm entry is .ok with that height")
    func validCentimeters() throws {
        let status = HeightEntry.validate(unit: .centimeters, fields: ["175"])
        #expect(try #require(status.cm) == 175)
    }

    @Test("An empty cm entry is .empty")
    func emptyCentimeters() {
        #expect(HeightEntry.validate(unit: .centimeters, fields: [""]) == .empty)
    }

    @Test("A below-range cm entry is .outOfRange")
    func belowRangeCentimeters() {
        // 50 cm is below the 100 cm floor.
        #expect(HeightEntry.validate(unit: .centimeters, fields: ["50"]) == .outOfRange)
    }

    @Test("An above-range cm entry is .outOfRange")
    func aboveRangeCentimeters() {
        // 300 cm is above the 272 cm ceiling.
        #expect(HeightEntry.validate(unit: .centimeters, fields: ["300"]) == .outOfRange)
    }

    @Test("A non-numeric cm entry is .unparseable")
    func unparseableCentimeters() {
        #expect(HeightEntry.validate(unit: .centimeters, fields: ["abc"]) == .unparseable)
    }

    @Test("A decimal cm entry is .unparseable (integer entry this pass)")
    func decimalCentimetersUnparseable() {
        #expect(HeightEntry.validate(unit: .centimeters, fields: ["175.5"]) == .unparseable)
    }

    // MARK: - Single field: inches

    @Test("A valid inches entry is .ok in cm")
    func validInches() throws {
        let status = HeightEntry.validate(unit: .inches, fields: ["69"])
        // 69 in ≈ 175.26 cm — in range.
        let cm = try #require(status.cm)
        #expect(abs(cm - 175.26) < 0.5)
    }

    @Test("A below-range inches entry is .outOfRange")
    func belowRangeInches() {
        // 12 in ≈ 30.48 cm, below the 100 cm floor.
        #expect(HeightEntry.validate(unit: .inches, fields: ["12"]) == .outOfRange)
    }

    @Test("An above-range inches entry is .outOfRange")
    func aboveRangeInches() {
        // 120 in ≈ 304.8 cm, above the 272 cm ceiling.
        #expect(HeightEntry.validate(unit: .inches, fields: ["120"]) == .outOfRange)
    }

    // MARK: - Feet & inches

    @Test("A valid feet & inches entry is .ok in cm")
    func validFeetAndInches() throws {
        let status = HeightEntry.validate(unit: .feetAndInches, fields: ["5", "9"])
        // 5 ft 9 in = 69 in ≈ 175.26 cm — in range.
        let cm = try #require(status.cm)
        #expect(abs(cm - 175.26) < 0.5)
    }

    @Test("Feet with an empty inches field reads as a zero remainder")
    func feetEmptyInches() throws {
        let status = HeightEntry.validate(unit: .feetAndInches, fields: ["5", ""])
        // 5 ft = 60 in ≈ 152.4 cm.
        let cm = try #require(status.cm)
        #expect(abs(cm - 152.4) < 0.5)
    }

    @Test("An inches remainder of 12 or more is .outOfRange (reject-and-nag)")
    func inchesRemainderTooLarge() {
        #expect(HeightEntry.validate(unit: .feetAndInches, fields: ["5", "12"]) == .outOfRange)
        #expect(HeightEntry.validate(unit: .feetAndInches, fields: ["0", "15"]) == .outOfRange)
    }

    @Test("Feet beyond the range is .outOfRange")
    func feetTooLarge() {
        // 10 ft = 120 in ≈ 304.8 cm, above the 272 cm ceiling.
        #expect(HeightEntry.validate(unit: .feetAndInches, fields: ["10", "0"]) == .outOfRange)
    }

    @Test("Both feet fields empty is .empty")
    func feetAndInchesEmpty() {
        #expect(HeightEntry.validate(unit: .feetAndInches, fields: ["", ""]) == .empty)
    }

    @Test("A non-numeric feet field is .unparseable")
    func feetUnparseable() {
        #expect(HeightEntry.validate(unit: .feetAndInches, fields: ["abc", "3"]) == .unparseable)
        #expect(HeightEntry.validate(unit: .feetAndInches, fields: ["5", "abc"]) == .unparseable)
    }

    // MARK: - MetricRanges.height

    @Test("MetricRanges.height is 100…272 cm")
    func heightRange() {
        #expect(MetricRanges.height == 100...272)
        #expect(MetricRanges.height.contains(100))
        #expect(MetricRanges.height.contains(272))
        #expect(!MetricRanges.height.contains(0))
        #expect(!MetricRanges.height.contains(99.9))
        #expect(!MetricRanges.height.contains(272.1))
    }

    // MARK: - The two gates agree (Decision 14 analog)

    @Test("Both gates agree on height: in-range valid, zero and out-of-range invalid")
    func gatesAgreeOnHeight() {
        let profile = makeProfile()

        // In range → valid on both gates.
        profile.height = 175
        #expect(profile.isHeightValid)
        #expect(profile.validateForCalculation() == nil)

        // Zero → invalid on both gates.
        profile.height = 0
        #expect(!profile.isHeightValid)
        #expect(profile.validateForCalculation()?.contains("Height") == true)

        // Above the ceiling → invalid on both gates.
        profile.height = 500
        #expect(!profile.isHeightValid)
        #expect(profile.validateForCalculation()?.contains("Height") == true)
    }

    // MARK: - Helpers

    /// A profile on its own in-memory store with every other field valid, so only height is under test.
    private func makeProfile() -> ProfileViewModel {
        let repository = SwiftDataContainer(isInMemory: true).profileRepository
        let profile = ProfileViewModel(profileRepository: repository)
        profile.age = 25
        profile.height = 175
        profile.weight = 70
        profile.bodyFatPercentageMethod = .omit
        return profile
    }
}
