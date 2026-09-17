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

        XCTAssertTrue(utils.waitForElement(app.segmentedControls["Gender"]), "Gender picker should exist")

        XCTAssertTrue(app.segmentedControls["Gender"].buttons["Male"].exists)
        XCTAssertTrue(app.segmentedControls["Gender"].buttons["Female"].exists)
    }
}
