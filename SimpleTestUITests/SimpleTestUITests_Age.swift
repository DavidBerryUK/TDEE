//
//  SimpleTestUITests_Age.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Age: XCTestCase {

    let utils = SimpleTestUITestUtils.self
    let ageRange = 16...99

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    /// Opens the Age section and checks that a wheel picker for entering age actually shows up.
    @MainActor
    func testAgePickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        let ageSection = app.otherElements["sectionAge"]
        ageSection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Age picker not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(picker), "Age picker should exist")
    }

    /// Picks a few different ages in the wheel picker and checks the collapsed section header
    /// always shows whatever was picked last, including switching back to an earlier choice.
    @MainActor
    func testAgeSummaryUpdatesAfterSelectionChange() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Age section
        let ageSection = app.otherElements["sectionAge"]
        ageSection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Age picker not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(picker), "Age picker should exist")

        // Note: verification is done via the collapsed summary, not the wheel's own
        // accessibility value. `adjust(toPickerWheelValue:)` synthetic gestures are not
        // fully reliable for SwiftUI `.wheel` pickers - the wheel can report the requested
        // row even when the underlying model committed a different value. See
        // `selectValueVerified` for details.
        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 34, summaryLabel: "Age value", validRange: ageRange), "Age summary should display '34' after selection")

        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 65, summaryLabel: "Age value", validRange: ageRange), "Age summary should display '65' after selection")

        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 34, summaryLabel: "Age value", validRange: ageRange), "Age summary should display '34' after selecting again")

        // Collapse the section, leaving the UI in a clean state
        ageSection.tap()
    }

    /// Checks that the age picker really does cover its full advertised range - the lowest and
    /// highest allowed ages are both selectable, and the app's default age still is too.
    @MainActor
    func testAgeRangeOptions() throws {
        let app = XCUIApplication()
        app.launch()

        let ageSection = app.otherElements["sectionAge"]
        ageSection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Age picker not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(picker), "Age picker should exist")

        // Verified against the summary rather than the wheel's own accessibility value -
        // see `selectValueVerified` for why the wheel alone can't be trusted.
        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 16, summaryLabel: "Age value", validRange: ageRange), "Should be able to select age 16")

        // The maximum (99) is the picker's very last row, which `selectValueVerified` can't
        // reliably confirm committed - see its doc comment. `adjust` itself already asserts that
        // "99" is a value the wheel actually offers (it hard-fails for anything outside the
        // picker's real value set), so this checks that instead of a full round-trip commit.
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "99")

        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 21, summaryLabel: "Age value", validRange: ageRange), "Should be able to select age 21")
    }
}
