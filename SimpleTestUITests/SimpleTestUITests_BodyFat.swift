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
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    @MainActor
    func testBodyFatMethodSelectorExists() throws {
        let app = XCUIApplication()
        app.launch()

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
        app.launch()

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
