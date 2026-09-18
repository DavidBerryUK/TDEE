//
//  SimpleTestUITests_Age.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Age: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

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
        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 34, summaryLabel: "Age value"), "Age summary should display '34' after selection")

        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 65, summaryLabel: "Age value"), "Age summary should display '65' after selection")

        XCTAssertTrue(utils.selectValueVerified(inSection: ageSection, value: 34, summaryLabel: "Age value"), "Age summary should display '34' after selecting again")

        // Collapse the section, leaving the UI in a clean state
        ageSection.tap()
    }

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

        // Verify minimum age (16) can be selected
        XCTAssertTrue(utils.selectValue(inPicker: picker, value: "16"), "Should be able to select age 16")

        // Verify maximum age (99) can be selected
        XCTAssertTrue(utils.selectValue(inPicker: picker, value: "99"), "Should be able to select age 99")

        // Verify default age (21) can be selected
        XCTAssertTrue(utils.selectValue(inPicker: picker, value: "21"), "Should be able to select age 21")
    }
}
