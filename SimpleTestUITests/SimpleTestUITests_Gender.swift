//
//  SimpleTestUITests_Gender.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Gender: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Reset app state to ensure clean isolation for parallel tests
        SimpleTestUITestUtils.resetAppState()
    }

    override func tearDownWithError() throws {
        // Clean up any expanded sections to leave the app in a known state
        let app = XCUIApplication()
        let section = app.otherElements["sectionGender"]
        // Only tap if the section is expanded (has a segmented control visible)
        if section.descendants(matching: .segmentedControl).firstMatch.exists {
            section.tap() // collapse
            sleep(1) // allow animation to complete
        }
        app.terminate()
        sleep(1)
    }

    /// Opens the Gender section and checks that a Male/Female selector actually shows up.
    @MainActor
    func testGenderSelectorExists() throws {
        let app = XCUIApplication()
        app.launch()

        let genderSection = app.otherElements["sectionGender"]
        genderSection.tap()

        let segmentedControl = utils.findSegmentedControl(in: app)
        if let segmentedControl = segmentedControl {
            XCTAssertTrue(utils.waitForElement(segmentedControl), "Gender segmented control should exist")

            XCTAssertTrue(segmentedControl.buttons["Male"].exists)
            XCTAssertTrue(segmentedControl.buttons["Female"].exists)
        } else {
            XCTFail("Gender segmented control not found in accessibility hierarchy")
        }
    }

    /// Switches gender from the default (Male) to Female and back, checking that the collapsed
    /// section header updates each time and that the selector itself remembers the choice when
    /// the section is re-expanded.
    @MainActor
    func testGenderSummaryUpdatesAfterSelectionChange() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Gender section
        let genderSection = app.otherElements["sectionGender"]
        genderSection.tap()

        // Verify initial selection is Male
        guard let segmentedControl = utils.findSegmentedControl(in: app) else {
            XCTFail("Gender segmented control not found in accessibility hierarchy")
            return
        }
        XCTAssertTrue(utils.waitForElement(segmentedControl), "Gender segmented control should exist")
        XCTAssertTrue(segmentedControl.buttons["Male"].isSelected, "Male should be selected by default")

        // Select Female
        segmentedControl.buttons["Female"].tap()

        // Collapse the section
        genderSection.tap()

        // Find and verify the summary value shows Female
        let genderValueText = utils.findSummaryValue(in: genderSection, withAccessibilityLabel: "Gender value")
        XCTAssertTrue(genderValueText?.exists ?? false, "Gender value text should exist")
        if let genderValue = genderValueText?.value as? String {
            XCTAssertTrue(genderValue == "Female", "Gender summary should display 'Female' after selection, got '\(genderValue)'")
        } else {
            XCTFail("Gender value text value is not a String")
        }

        // Expand the section again
        genderSection.tap()

        // Verify Female is still selected in the editor
        XCTAssertTrue(segmentedControl.buttons["Female"].isSelected, "Female should remain selected after re-expanding")

        // Select Male again
        segmentedControl.buttons["Male"].tap()

        // Collapse the section
        genderSection.tap()

        // Find and verify the summary value shows Male
        let genderValueTextMale = utils.findSummaryValue(in: genderSection, withAccessibilityLabel: "Gender value")
        XCTAssertTrue(genderValueTextMale?.exists ?? false, "Gender value text should exist after switching to Male")
        if let genderValue = genderValueTextMale?.value as? String {
            XCTAssertTrue(genderValue == "Male", "Gender summary should display 'Male' after selection, got '\(genderValue)'")
        } else {
            XCTFail("Gender value text value is not a String")
        }

        // Expand the section again
        genderSection.tap()

        // Verify Male is still selected in the editor
        XCTAssertTrue(segmentedControl.buttons["Male"].isSelected, "Male should remain selected after re-expanding")
    }
}
