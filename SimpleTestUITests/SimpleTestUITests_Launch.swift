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
        let section = app.otherElements["sectionHeight"]
        // Only tap if the section is expanded (has a picker wheel visible)
        if section.pickerWheels.firstMatch.exists {
            section.tap() // collapse
            sleep(1) // allow animation to complete
        }
        app.terminate()
        sleep(1)
    }

    @MainActor
    func testAppLaunchesWithCorrectTitle() throws {
        let app = XCUIApplication()

        // The navigation title varies by screen width:
        // - Compact width (iPhone): "TDEE"
        // - Regular width (iPad): "Total Daily Energy Expenditure"
        // Use staticText to find the navigation bar title since navigationBars["TDEE"] only works for exact match
        let navigationBarTitle = app.staticTexts["TDEE"].firstMatch
        let navigationBarTitleFull = app.staticTexts["Total Daily Energy Expenditure"].firstMatch

        XCTAssertTrue(navigationBarTitle.exists || navigationBarTitleFull.exists,
                      "Navigation bar should have a valid title (TDEE or Total Daily Energy Expenditure)")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

}
