//
//  SimpleTestUITests_Weight.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Weight: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

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
}
