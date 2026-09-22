//
//  SimpleTestUITests_ActivityLevel.swift
//  SimpleTestUITests
//
//  Created by David Berry on 20/09/2026.
//

import Foundation
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
    /// Puts the section into the requested state, rather than blindly toggling whatever state
    /// it happens to be in.
    ///
    /// The caller states its *intent* (`open: true` / `open: false`); this reads the section's
    /// current state from the disclosure control's accessibility value and taps only if the two
    /// differ, then waits for the UI to confirm the change. Being idempotent matters: a tap that
    /// missed, or a state that was not what the test assumed, previously flipped the section the
    /// wrong way and the test carried on into a confusing failure. Now a wrong assumption is a
    /// no-op and a missed tap is retried rather than corrupting a picker value.
    ///
    /// The chevron carries a stable identifier (`<sectionId>.disclosure`) and the `.isButton`
    /// trait, which makes it a `button` rather than an `image` in the accessibility tree, so it
    /// is looked up by identifier rather than by SF Symbol name. There is deliberately no
    /// `section.tap()` fallback: tapping the section's own frame is the bug this avoids.
    @discardableResult
    private func setSection(open: Bool, maxAttempts: Int = 3) -> Bool {
        let chevron = XCUIApplication().buttons["sectionActivityLevel.disclosure"]
        guard chevron.waitForExistence(timeout: 5.0) else {
            XCTFail("Activity Level disclosure button not found")
            return false
        }
        let target = open ? "expanded" : "collapsed"

        for _ in 1...maxAttempts {
            if chevron.value as? String == target { return true }
            chevron.tap()
            var elapsed: TimeInterval = 0
            while elapsed < 5.0 {
                if chevron.value as? String == target { return true }
                Thread.sleep(forTimeInterval: 0.05)
                elapsed += 0.05
            }
        }
        XCTFail("Activity Level section did not reach '\(target)'")
        return false
    }

    /// Selects an activity level by its full picker-wheel row name and verifies the section
    /// summary settles on the corresponding short name, retrying the adjustment if it doesn't
    /// match yet.
    @discardableResult
    private func selectActivityLevel(inSection section: XCUIElement, full: String, short: String, maxAttempts: Int = 3) -> Bool {
        let app = XCUIApplication()
        for _ in 1...maxAttempts {
            let wheel = utils.wheel("activityLevelPicker", in: app)
            guard wheel != nil else { return false }
            wheel!.adjust(toPickerWheelValue: full)

            let summary = utils.findSummaryValue(in: section, withAccessibilityLabel: "Activity level value")
            let actual = summary.flatMap { utils.waitForStableValue(of: $0) }
            if actual == short {
                return true
            }
        }
        return false
    }

    /// Collapses a section already showing `short` and confirms the summary still shows it once
    /// collapsed, re-selecting `full` if collapsing changed the value.
    @discardableResult
    private func collapseAndVerifyActivityLevel(inSection section: XCUIElement, full: String, short: String, maxAttempts: Int = 3) -> Bool {
        for attempt in 1...maxAttempts {
            setSection(open: false)

            let summary = utils.findSummaryValue(in: section, withAccessibilityLabel: "Activity level value")
            let actual = summary.flatMap { utils.waitForStableValue(of: $0) }
            if actual == short {
                return true
            }

            guard attempt < maxAttempts else { return false }

            setSection(open: true) // so the retry can drive the wheel again
            guard selectActivityLevel(inSection: section, full: full, short: short) else { return false }
        }
        return false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        utils.resetAppState()
    }

    /// Opens the Activity Level section and checks that the wheel picker shows up.
    @MainActor
    func testActivityLevelPickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        XCTAssertTrue(utils.setSection("sectionActivityLevel", open: true, in: app), "Section should expand")

        let picker = utils.wheel("activityLevelPicker", in: app)
        XCTAssertNotNil(picker, "Activity level picker should exist")
    }

    /// Selects each activity level and verifies the collapsed section header
    /// displays the correct display name.
    @MainActor
    func testActivityLevelAllCases() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        XCTAssertTrue(utils.setSection("sectionActivityLevel", open: true, in: app), "Section should expand")

        // Verify initial selection is Sedentary (default)
        let picker = utils.wheel("activityLevelPicker", in: app)
        XCTAssertNotNil(picker, "Activity level picker should exist")

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
            XCTAssertTrue(utils.setSection("sectionActivityLevel", open: true, in: app), "Section should expand")
        }
    }

    /// Verifies that the selected activity level persists when the section
    /// is collapsed and re-expanded.
    @MainActor
    func testActivityLevelValuePersistsAfterCollapseExpand() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        XCTAssertTrue(utils.setSection("sectionActivityLevel", open: true, in: app), "Section should expand")

        let picker = utils.wheel("activityLevelPicker", in: app)
        XCTAssertNotNil(picker, "Activity level picker should exist")

        // Select Athlete
        XCTAssertTrue(selectActivityLevel(inSection: activitySection, full: "Athlete (2x per day)", short: "Athlete"),
                      "Should be able to select Athlete")

        // Collapse and verify
        XCTAssertTrue(collapseAndVerifyActivityLevel(inSection: activitySection, full: "Athlete (2x per day)", short: "Athlete"),
                      "Value should persist after collapse/expand")

        // Re-expand and verify in-editor value
        XCTAssertTrue(utils.setSection("sectionActivityLevel", open: true, in: app), "Section should expand")
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
        XCTAssertTrue(utils.setSection("sectionActivityLevel", open: true, in: app), "Section should expand")

        let picker = utils.wheel("activityLevelPicker", in: app)
        XCTAssertNotNil(picker, "Picker should exist")

        // Start with default (Sedentary)
        XCTAssertTrue(utils.waitForElement(picker!), "Picker should exist")

        // Select Light Exercise
        XCTAssertTrue(selectActivityLevel(inSection: activitySection, full: "Light Exercise (1-2 days)", short: "Light Exercise"),
                      "Should be able to select Light Exercise")

        // Collapse and verify
        XCTAssertTrue(collapseAndVerifyActivityLevel(inSection: activitySection, full: "Light Exercise (1-2 days)", short: "Light Exercise"),
                      "Summary should show 'Light Exercise' after collapsing")

        // Re-expand, select Heavy Exercise, collapse again
        XCTAssertTrue(utils.setSection("sectionActivityLevel", open: true, in: app), "Section should expand")
        XCTAssertTrue(selectActivityLevel(inSection: activitySection, full: "Heavy Exercise (3-5 days)", short: "Heavy Exercise"),
                      "Should be able to select Heavy Exercise")

        XCTAssertTrue(collapseAndVerifyActivityLevel(inSection: activitySection, full: "Heavy Exercise (3-5 days)", short: "Heavy Exercise"),
                      "Summary should show 'Heavy Exercise' after collapsing")
    }
}
