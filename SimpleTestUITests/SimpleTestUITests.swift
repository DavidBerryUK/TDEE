//
//  SimpleTestUITests.swift
//  SimpleTestUITests
//
//  Created by David Berry on 31/03/2026.
//

import XCTest

final class SimpleTestUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Helper method to wait for element with a short delay to allow animations to complete
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 1.0) -> Bool {
        // Brief pause to allow animations to complete
        Thread.sleep(forTimeInterval: 0.25) // 250ms
        return element.waitForExistence(timeout: timeout)
    }

    @MainActor
    func testAppLaunchesWithCorrectTitle() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify the app launches with the expected navigation title
        let navigationBar = app.navigationBars["TDEE"]
        XCTAssertTrue(navigationBar.exists, "Navigation bar with 'TDEE' title should exist")
    }

    @MainActor
    func testBodyFatMethodSelectorExists() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Body Fat section first using accessibility identifier
        let bodyFatSection = app.otherElements["sectionBodyFatPercentage"]
        bodyFatSection.tap()

        // Wait for the section to expand before checking for the picker
        XCTAssertTrue(waitForElement(app.segmentedControls["BodyFatOption"]), "Body fat method picker should exist")

        // Verify it has the expected segments
        XCTAssertTrue(app.segmentedControls["BodyFatOption"].buttons["Omit"].exists)
        XCTAssertTrue(app.segmentedControls["BodyFatOption"].buttons["Estimate"].exists)
        XCTAssertTrue(app.segmentedControls["BodyFatOption"].buttons["Manual Entry"].exists)
    }

    @MainActor
    func testCanSelectManualBodyFatEntry() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Body Fat section first
        let bodyFatSection = app.otherElements["sectionBodyFatPercentage"]
        bodyFatSection.tap()

        // Wait for the section to expand before checking for the picker
        XCTAssertTrue(waitForElement(app.segmentedControls["BodyFatOption"]), "Body fat method picker should exist")

        // Select "Manual Entry"
        app.segmentedControls["BodyFatOption"].buttons["Manual Entry"].tap()

        // Wait for manual entry input to appear
        XCTAssertTrue(waitForElement(app.pickers["Body fat percentage picker"]), "Body fat percentage picker should exist after selecting manual entry")
    }

    @MainActor
    func testAgePickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Age section first
        let ageSection = app.otherElements["sectionAge"]
        ageSection.tap()

        XCTAssertTrue(waitForElement(app.pickers["agePicker"]), "Age picker should exist")
    }

    @MainActor
    func testWeightPickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Weight section first
        let weightSection = app.otherElements["sectionWeight"]
        weightSection.tap()

        XCTAssertTrue(waitForElement(app.pickers["weightKgPicker"]), "Weight picker should exist")
    }

    @MainActor
    func testHeightPickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Height section first
        let heightSection = app.otherElements["sectionHeight"]
        heightSection.tap()

        XCTAssertTrue(waitForElement(app.pickers["heightCmPicker"]), "Height picker should exist")
    }

    @MainActor
    func testGenderSelectorExists() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Age section to find the Gender picker ( Gender is in the Age section editor )
        let ageSection = app.otherElements["sectionAge"]
        ageSection.tap()

        // Wait for the section to expand before checking for the picker
        XCTAssertTrue(waitForElement(app.segmentedControls["Gender"]), "Gender picker should exist")

        XCTAssertTrue(app.segmentedControls["Gender"].buttons["Male"].exists)
        XCTAssertTrue(app.segmentedControls["Gender"].buttons["Female"].exists)
    }

    @MainActor
    func testAllInputSectionsVisible() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand each section using accessibility identifiers
        app.otherElements["sectionAge"].tap()
        app.otherElements["sectionWeight"].tap()
        app.otherElements["sectionHeight"].tap()
        app.otherElements["sectionBodyFatPercentage"].tap()

        // Wait for sections to expand before checking for pickers
        // Use a brief delay to allow all animations to complete
        Thread.sleep(forTimeInterval: 0.25) // 250ms delay

        // Now check the pickers are visible
        XCTAssertTrue(waitForElement(app.pickers["agePicker"]), "Age picker should be visible")
        XCTAssertTrue(waitForElement(app.pickers["weightKgPicker"]), "Weight picker should be visible")
        XCTAssertTrue(waitForElement(app.pickers["heightCmPicker"]), "Height picker should be visible")
        XCTAssertTrue(waitForElement(app.segmentedControls["BodyFatOption"]), "Body Fat option picker should be visible")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
