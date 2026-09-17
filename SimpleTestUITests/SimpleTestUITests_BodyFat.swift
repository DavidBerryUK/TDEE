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

        XCTAssertTrue(utils.waitForElement(app.segmentedControls["BodyFatOption"]), "Body fat method picker should exist")

        XCTAssertTrue(app.segmentedControls["BodyFatOption"].buttons["Omit"].exists)
        XCTAssertTrue(app.segmentedControls["BodyFatOption"].buttons["Estimate"].exists)
        XCTAssertTrue(app.segmentedControls["BodyFatOption"].buttons["Manual Entry"].exists)
    }

    @MainActor
    func testCanSelectManualBodyFatEntry() throws {
        let app = XCUIApplication()
        app.launch()

        let bodyFatSection = app.otherElements["sectionBodyFatPercentage"]
        bodyFatSection.tap()

        XCTAssertTrue(utils.waitForElement(app.segmentedControls["BodyFatOption"]), "Body fat method picker should exist")

        app.segmentedControls["BodyFatOption"].buttons["Manual Entry"].tap()

        let bodyFatPicker = utils.findPicker(in: app)
        if let bodyFatPicker = bodyFatPicker {
            XCTAssertTrue(utils.waitForElement(bodyFatPicker), "Body fat percentage picker should exist after selecting manual entry")
        } else {
            XCTFail("Body fat percentage picker not found in accessibility hierarchy")
        }
    }
}
