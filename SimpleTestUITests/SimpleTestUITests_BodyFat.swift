//
//  SimpleTestUITests_BodyFat.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import Foundation
import XCTest

final class SimpleTestUITests_BodyFat: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Clean up any expanded sections to leave the app in a known state
        utils.resetAppState()
    }

    @MainActor
    func testBodyFatMethodSelectorExists() throws {
        let app = XCUIApplication()

        app.launch()

        let bodyFatSection = app.otherElements["sectionBodyFatPercentage"]
        XCTAssertTrue(utils.setSection("sectionBodyFatPercentage", open: true, in: app), "Section should expand")

        let segmentedControl = utils.segmentedControl("bodyFatMethodSegmentedControl", in: app)
        XCTAssertNotNil(segmentedControl, "Body fat method segmented control should exist")

        XCTAssertTrue(segmentedControl!.buttons["Omit"].exists)
        XCTAssertTrue(segmentedControl!.buttons["Estimate"].exists)
        XCTAssertTrue(segmentedControl!.buttons["Manual Entry"].exists)
    }

    @MainActor
    func testCanSelectManualBodyFatEntry() throws {
        let app = XCUIApplication()
        app.launch()

        let bodyFatSection = app.otherElements["sectionBodyFatPercentage"]
        XCTAssertTrue(utils.setSection("sectionBodyFatPercentage", open: true, in: app), "Section should expand")

        let segmentedControl = utils.segmentedControl("bodyFatMethodSegmentedControl", in: app)
        XCTAssertNotNil(segmentedControl, "Body fat method segmented control should exist")

        segmentedControl!.buttons["Manual Entry"].tap()

        // Find body fat pickers (there are 2 for integer and decimal parts)
        let bodyFatWheel = utils.wheel("bodyFatPicker", in: app)
        let bodyFatDecimalWheel = utils.wheel("bodyFatDecimalPicker", in: app)
        XCTAssertNotNil(bodyFatWheel, "Body fat integer picker should exist after selecting manual entry")
        XCTAssertNotNil(bodyFatDecimalWheel, "Body fat decimal picker should exist after selecting manual entry")
    }
}
