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

        let picker = utils.findPicker(in: app)
        if let picker = picker {
            XCTAssertTrue(utils.waitForElement(picker), "Age picker should exist")
        } else {
            XCTFail("Age picker not found in accessibility hierarchy")
        }
    }

}
