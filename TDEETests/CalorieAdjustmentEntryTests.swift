//
//  CalorieAdjustmentEntryTests.swift
//  TDEETests
//
//  Story 023, input #11 — the pure CalorieAdjustmentEntry validator and the MetricRanges.calorieAdjustment
//  authority. Calorie adjustment carries no results gate (it is not in isValid / hasError), so — unlike
//  the weight / height / body-fat tests — there is no "two gates agree" suite here; the range drives
//  only the entry's reject-and-nag.
//

import Testing
@testable import TDEE
import Foundation

@Suite("CalorieAdjustmentEntry Tests")
@MainActor
struct CalorieAdjustmentEntryTests {

    // MARK: - Valid entries

    @Test("A valid adjustment entry is .ok with that value")
    func validEntry() throws {
        #expect((try #require(CalorieAdjustmentEntry.validate("250").calories)) == 250)
    }

    @Test("The 0 and 1000 boundaries are .ok")
    func boundaries() throws {
        #expect((try #require(CalorieAdjustmentEntry.validate("0").calories)) == 0)
        #expect((try #require(CalorieAdjustmentEntry.validate("1000").calories)) == 1000)
    }

    @Test("An empty entry is .empty")
    func emptyEntry() {
        #expect(CalorieAdjustmentEntry.validate("") == .empty)
        #expect(CalorieAdjustmentEntry.validate("  ") == .empty)
    }

    // MARK: - Out of range

    @Test("An above-range entry is .outOfRange")
    func aboveRange() {
        // 1001 is above the 1000 ceiling.
        #expect(CalorieAdjustmentEntry.validate("1001") == .outOfRange)
        #expect(CalorieAdjustmentEntry.validate("5000") == .outOfRange)
    }

    // MARK: - Unparseable

    @Test("A non-numeric entry is .unparseable")
    func unparseable() {
        #expect(CalorieAdjustmentEntry.validate("abc") == .unparseable)
    }

    @Test("A decimal entry is .unparseable (integer entry — the .numberPad prevents it)")
    func decimalIsUnparseable() {
        #expect(CalorieAdjustmentEntry.validate("25.5") == .unparseable)
    }

    @Test("A negative entry is .unparseable (defensive — the keyboard prevents it)")
    func negativeIsUnparseable() {
        #expect(CalorieAdjustmentEntry.validate("-1") == .unparseable)
    }

    // MARK: - MetricRanges.calorieAdjustment

    @Test("MetricRanges.calorieAdjustment is 0…1000")
    func calorieRange() {
        #expect(MetricRanges.calorieAdjustment == 0...1000)
        #expect(MetricRanges.calorieAdjustment.contains(0))
        #expect(MetricRanges.calorieAdjustment.contains(1000))
        #expect(!MetricRanges.calorieAdjustment.contains(1001))
        #expect(!MetricRanges.calorieAdjustment.contains(-1))
    }
}
