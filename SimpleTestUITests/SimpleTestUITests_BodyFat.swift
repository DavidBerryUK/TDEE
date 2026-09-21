//
//  SimpleTestUITests_BodyFat.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_BodyFat: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Terminate and relaunch to ensure clean state for parallel tests
        let app = XCUIApplication()
        app.terminate()
        sleep(1)
        app.launch()
        sleep(2)
    }

    override func tearDownWithError() throws {
        // Clean up any expanded sections to leave the app in a known state
        let app = XCUIApplication()
        let section = app.otherElements["sectionBodyFatPercentage"]
        // Only tap if the section is expanded (has a segmented control visible)
        if section.descendants(matching: .segmentedControl).firstMatch.exists {
            section.tap() // collapse
            sleep(1) // allow animation to complete
        }
        app.terminate()
        sleep(1)
    }

    @MainActor
    func testBodyFatMethodSelectorExists() throws {
        let app = XCUIApplication()

        let bodyFatSection = app.otherElements["sectionBodyFatPercentage"]
        bodyFatSection.tap()

        let segmentedControl = utils.findSegmentedControl(in: app)
        if let segmentedControl = segmentedControl {
            XCTAssertTrue(utils.waitForElement(segmentedControl), "Body fat method segmented control should exist")

            XCTAssertTrue(segmentedControl.buttons["Omit"].exists)
            XCTAssertTrue(segmentedControl.buttons["Estimate"].exists)
            XCTAssertTrue(segmentedControl.buttons["Manual Entry"].exists)
        } else {
            XCTFail("Body fat method segmented control not found in accessibility hierarchy")
        }
    }

    @MainActor
    func testCanSelectManualBodyFatEntry() throws {
        let app = XCUIApplication()

        let bodyFatSection = app.otherElements["sectionBodyFatPercentage"]
        bodyFatSection.tap()

        let segmentedControl = utils.findSegmentedControl(in: app)
        if let segmentedControl = segmentedControl {
            XCTAssertTrue(utils.waitForElement(segmentedControl), "Body fat method segmented control should exist")

            segmentedControl.buttons["Manual Entry"].tap()

            // Find body fat pickers (there are 2 for integer and decimal parts)
            let bodyFatPickers = utils.findPickers(in: app)
            XCTAssertTrue(bodyFatPickers.count >= 1, "Body fat percentage picker(s) should exist after selecting manual entry")
            if !bodyFatPickers.isEmpty {
                XCTAssertTrue(utils.waitForElement(bodyFatPickers[0]), "Body fat percentage picker should exist after selecting manual entry")
            }
        } else {
            XCTFail("Body fat method segmented control not found in accessibility hierarchy")
        }
    }
}
