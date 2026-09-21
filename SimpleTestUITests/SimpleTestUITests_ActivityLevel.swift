//
//  SimpleTestUITests_ActivityLevel.swift
//  SimpleTestUITests
//
//  Created by David Berry on 20/09/2026.
//

import XCTest

final class SimpleTestUITests_ActivityLevel: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    /// The picker wheel's rows use the full display name (e.g. "Sedentary (office job)"),
    /// but the section summary shows the short name (e.g. "Sedentary") - unlike Age/Height/
    /// Weight, this picker's values aren't integers, so the generic `selectValueVerified`/
    /// `collapseAndVerify` helpers (which call `adjust(toPickerWheelValue:)` with a stringified
    /// Int) don't apply here.
    let activityLevels: [(full: String, short: String)] = [
        ("Sedentary (office job)", "Sedentary"),
        ("Light Exercise (1-2 days)", "Light Exercise"),
        ("Moderate Exercise (3-5 days)", "Moderate Exercise"),
        ("Heavy Exercise (3-5 days)", "Heavy Exercise"),
        ("Athlete (2x per day)", "Athlete")
    ]

    /// Toggles the section's expanded/collapsed state by tapping its chevron rather than the
    /// section's own accessibility frame. When expanded, this section's frame spans its header
    /// *and* its editor (a wheel picker plus a label, ~275pt tall), so `XCUIElement.tap()` - which
    /// taps the frame's geometric center - lands inside the picker instead of the header row that
    /// actually owns the collapse/expand tap gesture, silently re-adjusting the wheel instead of
    /// toggling the section (confirmed via `debugDescription`: section frame
    /// `{16, 454, 408, 345}`, center y=626.5, well inside the editor which starts around y=524).
    /// The chevron sits in the header row at a fixed, small frame regardless of expansion state,
    /// so it's a reliable tap target either way.
    private func toggleSection(_ section: XCUIElement) {
        let chevron = section.images["chevron.down"]
        if chevron.waitForExistence(timeout: 2.0) {
            chevron.tap()
        } else {
            section.tap()
        }
    }

    /// Selects an activity level by its full picker-wheel row name and verifies the section
    /// summary settles on the corresponding short name, retrying the adjustment if it doesn't
    /// match yet (mirrors `SimpleTestUITestUtils.selectValueVerified`, but for this picker's
    /// string-valued rows rather than integer ones).
    @discardableResult
    private func selectActivityLevel(inSection section: XCUIElement, full: String, short: String, maxAttempts: Int = 3) -> Bool {
        let app = XCUIApplication()
        for _ in 1...maxAttempts {
            let wheel = app.pickerWheels.firstMatch
            guard wheel.waitForExistence(timeout: 2.0) else { return false }
            wheel.adjust(toPickerWheelValue: full)

            let summary = utils.findSummaryValue(in: section, withAccessibilityLabel: "Activity level value")
            let actual = summary.flatMap { utils.waitForStableValue(of: $0) }
            if actual == short {
                return true
            }
        }
        return false
    }

    /// Collapses a section already showing `short` and confirms the summary still shows it once
    /// collapsed, re-selecting `full` if collapsing changed the value (mirrors
    /// `SimpleTestUITestUtils.collapseAndVerify`, but for this picker's string-valued rows).
    @discardableResult
    private func collapseAndVerifyActivityLevel(inSection section: XCUIElement, full: String, short: String, maxAttempts: Int = 3) -> Bool {
        for attempt in 1...maxAttempts {
            toggleSection(section) // collapse

            let summary = utils.findSummaryValue(in: section, withAccessibilityLabel: "Activity level value")
            let actual = summary.flatMap { utils.waitForStableValue(of: $0) }
            if actual == short {
                return true
            }

            guard attempt < maxAttempts else { return false }

            toggleSection(section) // re-expand so the retry can drive the wheel again
            guard selectActivityLevel(inSection: section, full: full, short: short) else { return false }
        }
        return false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Reset app state to ensure clean isolation for parallel tests
        SimpleTestUITestUtils.resetAppState()
    }

    override func tearDownWithError() throws {
        // Clean up any expanded sections to leave the app in a known state
        let app = XCUIApplication()
        let section = app.otherElements["sectionActivityLevel"]
        // Only tap if the section is expanded (has a picker wheel visible)
        if section.pickerWheels.firstMatch.exists {
            toggleSection(section) // collapse
            sleep(1) // allow animation to complete
        }
        app.terminate()
        sleep(1)
    }

    /// Opens the Activity Level section and checks that the wheel picker shows up.
    @MainActor
    func testActivityLevelPickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        // Ensure section is collapsed first, then expand
        let activitySection = app.otherElements["sectionActivityLevel"]
        if activitySection.exists {
            // If section header exists but picker doesn't, section is collapsed
            // Tap to expand
            toggleSection(activitySection)
            Thread.sleep(forTimeInterval: 0.3)
        }

        let picker = utils.findPicker(in: app)
        if let picker = picker {
            XCTAssertTrue(utils.waitForElement(picker), "Activity level picker should exist")
        } else {
            XCTFail("Activity level picker not found in accessibility hierarchy")
        }
    }

    /// Selects each activity level and verifies the collapsed section header
    /// displays the correct display name.
    @MainActor
    func testActivityLevelAllCases() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        toggleSection(activitySection)

        // Verify initial selection is Sedentary (default)
        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Activity level picker not found")
            return
        }

        XCTAssertTrue(utils.waitForElement(picker), "Activity level picker should exist")

        // Check initial value is Sedentary
        let summary = utils.findSummaryValue(in: activitySection, withAccessibilityLabel: "Activity level value")
        XCTAssertTrue(summary?.exists ?? false, "Activity level summary should exist")
        let initialValue = utils.waitForStableValue(of: summary!)
        XCTAssertTrue(initialValue == "Sedentary",
                      "Initial value should be Sedentary, got '\(initialValue ?? "")'")

        for level in activityLevels {
            XCTAssertTrue(selectActivityLevel(inSection: activitySection, full: level.full, short: level.short),
                          "Should be able to select '\(level.short)'")

            XCTAssertTrue(collapseAndVerifyActivityLevel(inSection: activitySection, full: level.full, short: level.short),
                          "Summary should show '\(level.short)' after collapsing")

            // Re-expand for next iteration
            toggleSection(activitySection)
        }
    }

    /// Verifies that the selected activity level persists when the section
    /// is collapsed and re-expanded.
    @MainActor
    func testActivityLevelValuePersistsAfterCollapseExpand() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        toggleSection(activitySection)

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Activity level picker not found")
            return
        }

        // Select Athlete
        XCTAssertTrue(selectActivityLevel(inSection: activitySection, full: "Athlete (2x per day)", short: "Athlete"),
                      "Should be able to select Athlete")

        // Collapse and verify
        XCTAssertTrue(collapseAndVerifyActivityLevel(inSection: activitySection, full: "Athlete (2x per day)", short: "Athlete"),
                      "Value should persist after collapse/expand")

        // Re-expand and verify in-editor value
        toggleSection(activitySection)
        let summary = utils.findSummaryValue(in: activitySection, withAccessibilityLabel: "Activity level value")
        XCTAssertTrue(summary?.exists ?? false, "Activity level summary should exist")
        let value = utils.waitForStableValue(of: summary!)
        XCTAssertTrue(value == "Athlete", "Editor should show 'Athlete', got '\(value ?? "")'")
    }

    /// Verifies that selecting a new activity level updates the summary
    /// value correctly.
    @MainActor
    func testActivityLevelSummaryUpdatesAfterSelectionChange() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        toggleSection(activitySection)

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Activity level picker not found")
            return
        }

        // Start with default (Sedentary)
        XCTAssertTrue(utils.waitForElement(picker), "Picker should exist")

        // Select Light Exercise
        XCTAssertTrue(selectActivityLevel(inSection: activitySection, full: "Light Exercise (1-2 days)", short: "Light Exercise"),
                      "Should be able to select Light Exercise")

        // Collapse and verify
        XCTAssertTrue(collapseAndVerifyActivityLevel(inSection: activitySection, full: "Light Exercise (1-2 days)", short: "Light Exercise"),
                      "Summary should show 'Light Exercise' after collapsing")

        // Re-expand, select Heavy Exercise, collapse again
        toggleSection(activitySection)
        XCTAssertTrue(selectActivityLevel(inSection: activitySection, full: "Heavy Exercise (3-5 days)", short: "Heavy Exercise"),
                      "Should be able to select Heavy Exercise")

        XCTAssertTrue(collapseAndVerifyActivityLevel(inSection: activitySection, full: "Heavy Exercise (3-5 days)", short: "Heavy Exercise"),
                      "Summary should show 'Heavy Exercise' after collapsing")
    }
}
