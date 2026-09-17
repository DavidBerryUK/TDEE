//
//  SimpleTestUITests_Height.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Height: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    @MainActor
    func testHeightPickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        let heightSection = app.otherElements["sectionHeight"]
        heightSection.tap()

        let picker = utils.findPicker(in: app)
        if let picker = picker {
            XCTAssertTrue(utils.waitForElement(picker), "Height picker should exist")
        } else {
            XCTFail("Height picker not found in accessibility hierarchy")
        }
    }
}
