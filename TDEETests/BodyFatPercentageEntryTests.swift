//
//  BodyFatPercentageEntryTests.swift
//  TDEETests
//
//  Story 023, input #7 — the pure BodyFatPercentageEntry validator, the MetricRanges.bodyFatPercentage
//  gate, and the two model gates that must agree on body fat (Decision 21, the asymmetric variant of
//  Decision 14).
//

import Testing
@testable import TDEE
import Foundation

@Suite("BodyFatPercentageEntry Tests")
@MainActor
struct BodyFatPercentageEntryTests {

    // MARK: - Valid decimal entries

    @Test("A valid percentage entry is .ok with that value")
    func validPercentage() throws {
        let status = BodyFatPercentageEntry.validate("15.7")
        #expect(abs((try #require(status.value)) - 15.7) < 0.001)
    }

    @Test("Whole-number entries parse as .ok")
    func wholeNumberEntry() throws {
        #expect(abs((try #require(BodyFatPercentageEntry.validate("5").value)) - 5.0) < 0.001)
        #expect(abs((try #require(BodyFatPercentageEntry.validate("50").value)) - 50.0) < 0.001)
    }

    @Test("An empty entry is .empty")
    func emptyEntry() {
        #expect(BodyFatPercentageEntry.validate("") == .empty)
        #expect(BodyFatPercentageEntry.validate("  ") == .empty)
    }

    // MARK: - Rounding to 1 dp (Decision 20)

    @Test("A multi-decimal entry rounds to one decimal place")
    func roundsToOneDecimalPlace() throws {
        // 15.75 → 15.8 (half away from zero), matching the Classic's integer + decimal wheels.
        #expect(abs((try #require(BodyFatPercentageEntry.validate("15.75").value)) - 15.8) < 0.001)
    }

    @Test("A trailing dot reads as the whole number, not unparseable")
    func trailingDotReadsAsWhole() throws {
        // The .decimalPad produces "15." transiently; it parses as 15.0 so the user sees no mid-typing error.
        #expect(abs((try #require(BodyFatPercentageEntry.validate("15.").value)) - 15.0) < 0.001)
    }

    // MARK: - Out of range

    @Test("A below-range entry is .outOfRange")
    func belowRange() {
        // 4.9% is below the 5% floor.
        #expect(BodyFatPercentageEntry.validate("4.9") == .outOfRange)
    }

    @Test("An above-range entry is .outOfRange")
    func aboveRange() {
        // 50.1% is above the 50% ceiling.
        #expect(BodyFatPercentageEntry.validate("50.1") == .outOfRange)
    }

    // MARK: - Unparseable

    @Test("A non-numeric entry is .unparseable")
    func unparseable() {
        #expect(BodyFatPercentageEntry.validate("abc") == .unparseable)
    }

    @Test("Multiple decimal points are .unparseable")
    func multipleDecimalPoints() {
        #expect(BodyFatPercentageEntry.validate("15.7.2") == .unparseable)
    }

    @Test("A negative entry is .unparseable (defensive — the keyboard prevents it)")
    func negativeIsUnparseable() {
        #expect(BodyFatPercentageEntry.validate("-5") == .unparseable)
    }

    // MARK: - MetricRanges.bodyFatPercentage

    @Test("MetricRanges.bodyFatPercentage is 5…50")
    func bodyFatRange() {
        #expect(MetricRanges.bodyFatPercentage == 5...50)
        #expect(MetricRanges.bodyFatPercentage.contains(5))
        #expect(MetricRanges.bodyFatPercentage.contains(50))
        #expect(!MetricRanges.bodyFatPercentage.contains(0))
        #expect(!MetricRanges.bodyFatPercentage.contains(4.9))
        #expect(!MetricRanges.bodyFatPercentage.contains(50.1))
    }

    // MARK: - The two gates agree (Decision 21 — the asymmetric variant of Decision 14)

    @Test("In-range manual entry is valid on both gates")
    func manualEntryInRangeValidOnBothGates() {
        let profile = makeProfile()
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 15.0
        #expect(profile.isBodyFatValid)
        #expect(profile.validateForCalculation() == nil)
    }

    @Test("Below-range manual entry is invalid on both gates")
    func manualEntryBelowRangeInvalidOnBothGates() {
        let profile = makeProfile()
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 4.9
        #expect(!profile.isBodyFatValid)
        #expect(profile.validateForCalculation()?.contains("Body Fat Percentage") == true)
    }

    @Test("Above-range manual entry is invalid on both gates")
    func manualEntryAboveRangeInvalidOnBothGates() {
        let profile = makeProfile()
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 55
        #expect(!profile.isBodyFatValid)
        #expect(profile.validateForCalculation()?.contains("Body Fat Percentage") == true)
    }

    @Test("The gate is method-gated: Omit and Estimate never trip, even out of range")
    func methodGatedNeverTripsForOmitEstimate() {
        let profile = makeProfile()
        // A 0.0 value is out of the 5–50 range, but Omit / Estimate carry no % value to validate.
        profile.bodyFatPercentage = 0.0
        profile.bodyFatPercentageMethod = .omit
        #expect(profile.isBodyFatValid)
        #expect(profile.validateForCalculation() == nil)

        profile.bodyFatPercentageMethod = .estimate
        #expect(profile.isBodyFatValid)
        #expect(profile.validateForCalculation() == nil)
    }

    // MARK: - Helpers

    /// A profile on its own in-memory store with every other field valid, so only body fat is under
    /// test.
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
