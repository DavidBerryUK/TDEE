//
//  SimpleTestUITests_Weight.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Weight: XCTestCase {

    let utils = SimpleTestUITestUtils.self
    let kgRange = 0...250

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    /// Opens the Weight section and checks that a wheel picker for entering weight actually
    /// shows up.
    @MainActor
    func testWeightPickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        let weightSection = app.otherElements["sectionWeight"]
        weightSection.tap()

        let picker = utils.findPicker(in: app)
        if let picker = picker {
            XCTAssertTrue(utils.waitForElement(picker), "Weight picker should exist")
        } else {
            XCTFail("Weight picker not found in accessibility hierarchy")
        }
    }

    /// Picks a weight in kilograms and checks the collapsed section header shows that value
    /// and the "kg" unit once the section is collapsed.
    @MainActor
    func testWeightSummaryUpdatesAfterSelectionChange() throws {
        let app = XCUIApplication()
        app.launch()

        let weightSection = app.otherElements["sectionWeight"]
        weightSection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Weight picker not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(picker), "Weight picker should exist")

        // The Weight editor keeps the kg/pounds/stones-and-pounds wheels all mounted at once -
        // see `selectValueVerified`'s `wheelIndex` doc comment. Kilograms is the default unit
        // and sits at index 0.
        XCTAssertTrue(utils.selectValueVerified(inSection: weightSection, value: 95, summaryLabel: "Weight major value", validRange: kgRange), "Weight summary should display '95' after selection")

        let majorUnit = utils.findSummaryValue(in: weightSection, withAccessibilityLabel: "Weight major units")
        XCTAssertEqual(majorUnit?.value as? String, "kg", "Weight summary should display 'kg' as the unit")

        // Collapse the section, leaving the UI in a clean state
        weightSection.tap()
    }

    /// Selects a weight once in kilograms, then switches the unit selector through Pounds and
    /// Stones & Pounds, checking the collapsed section header is converted and redisplayed
    /// correctly each time - not just the in-editor wheel value.
    @MainActor
    func testWeightSummaryUpdatesWithUnitOfMeasureChange() throws {
        let app = XCUIApplication()
        app.launch()

        let weightSection = app.otherElements["sectionWeight"]
        weightSection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Weight picker not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(picker), "Weight picker should exist")

        // 100 kg converts to a clean 15 stones 11 pounds (220 total pounds), so the expected
        // values below aren't sensitive to floating point rounding under normal circumstances -
        // though the retries below do nudge away from 100 if collapsing perturbs the committed
        // value.
        var kgTarget = 100
        XCTAssertTrue(utils.selectValueVerified(inSection: weightSection, value: kgTarget, summaryLabel: "Weight major value", validRange: kgRange), "Weight summary should display '100' after selection")

        guard let unitSelector = utils.findSegmentedControl(in: app) else {
            XCTFail("Weight unit selector not found in accessibility hierarchy")
            return
        }

        // Switch to Pounds and check the header, not just the wheel. Collapsing can itself
        // perturb the committed value (see `verifyWithRetry`'s doc comment) - there's no pounds
        // wheel to nudge directly here (the pounds wheel is a different pickerWheel element),
        // so recovery instead nudges the underlying kilograms value by the observed pounds error
        // (mirroring `WeightConvertor.toPounds`'s own kg-to-pounds ratio) and re-attempts the
        // switch from there.
        let switchedToPounds = utils.verifyWithRetry(inSection: weightSection, expected: "220", summaryLabel: "Weight major value", steps: {
            let selector = app.descendants(matching: .segmentedControl).firstMatch
            selector.buttons["Pounds"].tap()
            weightSection.tap() // collapse to read the real committed summary
        }, recover: { actual in
            weightSection.tap() // re-expand
            let selector = app.descendants(matching: .segmentedControl).firstMatch
            selector.buttons["Kg"].tap()
            if let actualPounds = actual.flatMap({ Int($0) }) {
                let poundsError = 220 - actualPounds
                let kgNudge = Int((Double(poundsError) * 0.45359237).rounded())
                kgTarget = min(max(kgTarget + kgNudge, kgRange.lowerBound), kgRange.upperBound)
            }
            _ = utils.selectValueVerified(inSection: weightSection, value: kgTarget, summaryLabel: "Weight major value", validRange: kgRange)
        })
        XCTAssertTrue(switchedToPounds, "Weight summary should display '220' after switching to Pounds")

        let majorUnitPounds = utils.findSummaryValue(in: weightSection, withAccessibilityLabel: "Weight major units")
        XCTAssertEqual(majorUnitPounds?.value as? String, "pounds", "Weight summary should display 'pounds' as the unit")

        // Switch to Stones & Pounds and check the header again. kgTarget is whatever value the
        // Pounds check above converged on, still reliably converting to 15 stones 11 pounds.
        // This needs both the major (stones) and minor (pounds) readings to match - `verifyWithRetry`
        // only compares one label, so this drives the same retry-with-correction manually,
        // correcting kg by the *total* pounds error (15 stones 9 pounds is off by 2 pounds overall,
        // even though the stones digit alone already reads correctly as "15").
        var switchedToStones = false
        for attempt in 1...3 {
            let selector = app.descendants(matching: .segmentedControl).firstMatch
            selector.buttons["Stones & Pounds"].tap()
            weightSection.tap() // collapse to read the real committed summary

            let majorStones = utils.findSummaryValue(in: weightSection, withAccessibilityLabel: "Weight major value")
                .flatMap { utils.waitForStableValue(of: $0) }
            let minorPounds = utils.findSummaryValue(in: weightSection, withAccessibilityLabel: "Weight minor value")
                .flatMap { utils.waitForStableValue(of: $0) }

            if majorStones == "15" && minorPounds == "11" {
                switchedToStones = true
                break
            }

            guard attempt < 3 else { break }

            weightSection.tap() // re-expand
            let kgSelector = app.descendants(matching: .segmentedControl).firstMatch
            kgSelector.buttons["Kg"].tap()
            if let stones = majorStones.flatMap({ Int($0) }), let pounds = minorPounds.flatMap({ Int($0) }) {
                let totalPoundsError = 220 - (stones * 14 + pounds)
                let kgNudge = Int((Double(totalPoundsError) * 0.45359237).rounded())
                kgTarget = min(max(kgTarget + kgNudge, kgRange.lowerBound), kgRange.upperBound)
            }
            _ = utils.selectValueVerified(inSection: weightSection, value: kgTarget, summaryLabel: "Weight major value", validRange: kgRange)
        }
        XCTAssertTrue(switchedToStones, "Weight summary should display '15' stones, '11' pounds after switching to Stones & Pounds")

        let majorUnitStones = utils.findSummaryValue(in: weightSection, withAccessibilityLabel: "Weight major units")
        let minorUnitPounds = utils.findSummaryValue(in: weightSection, withAccessibilityLabel: "Weight minor units")
        XCTAssertEqual(majorUnitStones?.value as? String, "stones", "Weight summary should display 'stones' as the major unit")
        XCTAssertEqual(minorUnitPounds?.value as? String, "pounds", "Weight summary should display 'pounds' as the minor unit")
    }

    /// Confirms the "Please enter a valid Weight" error shown while weight is 0 disappears once
    /// a real weight has been picked.
    @MainActor
    func testWeightValidationClearsAfterSelection() throws {
        let app = XCUIApplication()
        app.launch()

        let weightSection = app.otherElements["sectionWeight"]
        weightSection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Weight picker not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(picker), "Weight picker should exist")

        XCTAssertTrue(app.staticTexts["Please enter a valid Weight"].exists, "Validation message should be visible while weight is 0")

        XCTAssertTrue(utils.selectValueVerified(inSection: weightSection, value: 95, summaryLabel: "Weight major value", validRange: kgRange), "Weight summary should display '95' after selection")

        XCTAssertFalse(app.staticTexts["Please enter a valid Weight"].exists, "Validation message should be cleared once a valid weight is selected")
    }
}
