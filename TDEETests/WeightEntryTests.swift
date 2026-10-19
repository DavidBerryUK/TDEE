//
//  WeightEntryTests.swift
//  TDEETests
//
//  Story 023, inputs #3 / #4 — the pure WeightEntry validator, the MetricRanges.weight gate, and the
//  two model gates that must agree on weight (Decision 14).
//

import Testing
@testable import TDEE
import Foundation

@Suite("WeightEntry Tests")
@MainActor
struct WeightEntryTests {

    // MARK: - Single field: kilograms

    @Test("A valid kg entry is .ok with that weight")
    func validKilograms() throws {
        let status = WeightEntry.validate(unit: .kilograms, fields: ["70"])
        #expect(try #require(status.kg) == 70)
    }

    @Test("An empty kg entry is .empty")
    func emptyKilograms() {
        #expect(WeightEntry.validate(unit: .kilograms, fields: [""]) == .empty)
    }

    @Test("A below-range kg entry is .outOfRange")
    func belowRangeKilograms() {
        #expect(WeightEntry.validate(unit: .kilograms, fields: ["5"]) == .outOfRange)
    }

    @Test("An above-range kg entry is .outOfRange")
    func aboveRangeKilograms() {
        #expect(WeightEntry.validate(unit: .kilograms, fields: ["400"]) == .outOfRange)
    }

    @Test("A non-numeric kg entry is .unparseable")
    func unparseableKilograms() {
        #expect(WeightEntry.validate(unit: .kilograms, fields: ["abc"]) == .unparseable)
    }

    @Test("A decimal kg entry is .unparseable (integer entry this pass)")
    func decimalKilogramsUnparseable() {
        #expect(WeightEntry.validate(unit: .kilograms, fields: ["70.5"]) == .unparseable)
    }

    // MARK: - Single field: pounds

    @Test("A valid pounds entry is .ok in kg")
    func validPounds() throws {
        let status = WeightEntry.validate(unit: .pounds, fields: ["154"])
        // 154 lb ≈ 69.85 kg — in range.
        let kg = try #require(status.kg)
        #expect(abs(kg - 69.85) < 0.5)
    }

    @Test("A below-range pounds entry is .outOfRange")
    func belowRangePounds() {
        // 14 lb ≈ 6.35 kg, below the 20 kg floor.
        #expect(WeightEntry.validate(unit: .pounds, fields: ["14"]) == .outOfRange)
    }

    @Test("An above-range pounds entry is .outOfRange")
    func aboveRangePounds() {
        // 1000 lb ≈ 453 kg, above the 300 kg ceiling.
        #expect(WeightEntry.validate(unit: .pounds, fields: ["1000"]) == .outOfRange)
    }

    // MARK: - Stones & pounds

    @Test("A valid stones entry is .ok in kg")
    func validStones() throws {
        let status = WeightEntry.validate(unit: .stonesAndPounds, fields: ["11", "3"])
        // 11 st 3 lb = 157 lb ≈ 71.2 kg — in range.
        let kg = try #require(status.kg)
        #expect(abs(kg - 71.2) < 0.5)
    }

    @Test("Stones with an empty pounds field reads as a zero remainder")
    func stonesEmptyPounds() throws {
        let status = WeightEntry.validate(unit: .stonesAndPounds, fields: ["11", ""])
        // 11 st = 154 lb ≈ 69.85 kg.
        let kg = try #require(status.kg)
        #expect(abs(kg - 69.85) < 0.5)
    }

    @Test("A pounds remainder of 14 or more is .outOfRange (reject-and-nag)")
    func poundsRemainderTooLarge() {
        #expect(WeightEntry.validate(unit: .stonesAndPounds, fields: ["11", "14"]) == .outOfRange)
        #expect(WeightEntry.validate(unit: .stonesAndPounds, fields: ["0", "20"]) == .outOfRange)
    }

    @Test("Stones above 40 is .outOfRange")
    func stonesTooLarge() {
        #expect(WeightEntry.validate(unit: .stonesAndPounds, fields: ["41", "0"]) == .outOfRange)
    }

    @Test("Both stones fields empty is .empty")
    func stonesEmpty() {
        #expect(WeightEntry.validate(unit: .stonesAndPounds, fields: ["", ""]) == .empty)
    }

    @Test("A non-numeric stones field is .unparseable")
    func stonesUnparseable() {
        #expect(WeightEntry.validate(unit: .stonesAndPounds, fields: ["abc", "3"]) == .unparseable)
        #expect(WeightEntry.validate(unit: .stonesAndPounds, fields: ["11", "abc"]) == .unparseable)
    }

    // MARK: - MetricRanges.weight

    @Test("MetricRanges.weight is 20…300 kg")
    func weightRange() {
        #expect(MetricRanges.weight == 20...300)
        #expect(MetricRanges.weight.contains(20))
        #expect(MetricRanges.weight.contains(300))
        #expect(!MetricRanges.weight.contains(0))
        #expect(!MetricRanges.weight.contains(19.9))
        #expect(!MetricRanges.weight.contains(300.1))
    }

    // MARK: - The two gates agree (Decision 14)

    @Test("Both gates agree on weight: in-range valid, zero and out-of-range invalid")
    func gatesAgreeOnWeight() {
        let profile = makeProfile()

        // In range → valid on both gates.
        profile.weight = 70
        #expect(profile.isWeightValid)
        #expect(profile.validateForCalculation() == nil)

        // Zero → invalid on both gates.
        profile.weight = 0
        #expect(!profile.isWeightValid)
        #expect(profile.validateForCalculation()?.contains("Weight") == true)

        // Above the ceiling → invalid on both gates.
        profile.weight = 500
        #expect(!profile.isWeightValid)
        #expect(profile.validateForCalculation()?.contains("Weight") == true)
    }

    // MARK: - Helpers

    /// A profile on its own in-memory store with every other field valid, so only weight is under test.
    private func makeProfile() -> ProfileViewModel {
        let repository = SwiftDataContainer(isInMemory: true).profileRepository
        let profile = ProfileViewModel(profileRepository: repository)
        profile.age = 25
        profile.height = 175
        profile.bodyFatPercentageMethod = .omit
        return profile
    }
}
