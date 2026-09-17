//
//  SimpleTestUITests_Launch.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Launch: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    @MainActor
    func testAppLaunchesWithCorrectTitle() throws {
        let app = XCUIApplication()
        app.launch()

        let navigationBar = app.navigationBars["TDEE"]
        XCTAssertTrue(navigationBar.exists, "Navigation bar with 'TDEE' title should exist")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testAllInputSectionsVisible() throws {
        let app = XCUIApplication()
        app.launch()

        app.otherElements["sectionAge"].tap()
        app.otherElements["sectionWeight"].tap()
        app.otherElements["sectionHeight"].tap()
        app.otherElements["sectionBodyFatPercentage"].tap()

        Thread.sleep(forTimeInterval: 0.25)

        let allDescendants = app.descendants(matching: .any)
        let count = allDescendants.count
        var pickerCount = 0
        for i in 0..<count {
            let element = allDescendants.element(boundBy: i)
            if element.elementType == XCUIElement.ElementType.picker {
                pickerCount += 1
            }
        }
        XCTAssertTrue(pickerCount >= 3, "Expected at least 3 pickers in the hierarchy")
        XCTAssertTrue(utils.waitForElement(app.segmentedControls["BodyFatOption"]), "Body Fat option picker should be visible")
    }
}
