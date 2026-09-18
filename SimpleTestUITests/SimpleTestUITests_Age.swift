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

        // Verify initial selection is 21 (default)
        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Age picker not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(picker), "Age picker should exist")

        // Select a different age (34)
        XCTAssertTrue(utils.selectValue(inPicker: picker, value: "34"), "Should select age 34")

        // Collapse the section
        ageSection.tap()

        // Find and verify the summary value shows 34
        let ageValueText = utils.findSummaryValue(in: ageSection, withAccessibilityLabel: "Age value")
        XCTAssertTrue(ageValueText?.exists ?? false, "Age value text should exist")
        if let ageValue = ageValueText?.value as? String {
            XCTAssertTrue(ageValue == "34", "Age summary should display '34' after selection, got '\(ageValue)'")
        } else {
            XCTFail("Age value text value is not a String")
        }

        // Expand the section again
        ageSection.tap()

        // Verify 34 is still selected in the editor
        XCTAssertTrue(utils.selectValue(inPicker: picker, value: "65"), "Should select age 65")

        // Collapse the section
        ageSection.tap()

        // Find and verify the summary value shows 65
        let ageValueText65 = utils.findSummaryValue(in: ageSection, withAccessibilityLabel: "Age value")
        XCTAssertTrue(ageValueText65?.exists ?? false, "Age value text should exist after switching to 65")
        if let ageValue = ageValueText65?.value as? String {
            XCTAssertTrue(ageValue == "65", "Age summary should display '65' after selection, got '\(ageValue)'")
        } else {
            XCTFail("Age value text value is not a String")
        }

        // Expand the section again
        ageSection.tap()

        // Verify 65 is still selected in the editor
        XCTAssertTrue(picker.buttons["65"].isSelected, "65 should remain selected after re-expanding")
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

        // Verify minimum age (16) exists
        XCTAssertTrue(picker.buttons["16"].exists, "Minimum age option '16' should exist")

        // Verify maximum age (99) exists
        XCTAssertTrue(picker.buttons["99"].exists, "Maximum age option '99' should exist")

        // Verify default age (21) is selected
        XCTAssertTrue(picker.buttons["21"].isSelected, "Default age '21' should be selected")
    }
}
