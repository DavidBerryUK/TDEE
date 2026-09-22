//
//  SimpleTestUITests_Launch.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import Foundation
import XCTest

final class SimpleTestUITests_Launch: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        utils.resetAppState()
    }

    @MainActor
    func testAppLaunchesWithCorrectTitle() throws {
        let app = XCUIApplication()
        app.launch()

        // The navigation title varies by screen width:
        // - Compact width (iPhone): "TDEE"
        // - Regular width (iPad): "Total Daily Energy Expenditure"
        // Use staticText to find the navigation bar title since navigationBars["TDEE"] only works for exact match
        let navigationBarTitle = app.staticTexts["TDEE"]
        let navigationBarTitleFull = app.staticTexts["Total Daily Energy Expenditure"]

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
