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
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

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
}
