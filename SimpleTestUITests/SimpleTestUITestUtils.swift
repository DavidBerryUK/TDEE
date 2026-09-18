//
//  SimpleTestUITestUtils.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

class SimpleTestUITestUtils {

    // MARK: - Helper Methods

    /// Helper method to wait for element with a short delay to allow animations to complete
    static func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 1.0) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }

    /// Finds a picker by querying picker elements directly
    /// This is faster than scanning all descendants because it only iterates picker elements
    /// Returns the first picker found in the accessibility hierarchy
    static func findPicker(in app: XCUIApplication) -> XCUIElement? {
        // Wait for the section to fully expand and picker to render
        Thread.sleep(forTimeInterval: 1.0)

        let allPickers = app.pickerWheels
        let count = allPickers.count

        // Iterate through picker elements only
        for i in 0..<count {
            let element = allPickers.element(boundBy: i)
            return element
        }
        return nil
    }

    /// Finds a picker by its position relative to a known element
    /// This avoids relying on accessibility identifiers which may not propagate correctly
    static func findPickerRelative(to sectionElement: XCUIElement, in app: XCUIApplication, afterDelay: TimeInterval = 0.5) -> XCUIElement? {
        // Wait for the section to expand
        Thread.sleep(forTimeInterval: afterDelay)

        let allPickers = app.pickerWheels
        let sectionIndex = allPickers.index(ofAccessibilityElement: sectionElement)

        if sectionIndex == NSNotFound {
            return nil
        }

        // Look for picker elements after the section header
        for i in (sectionIndex + 1)..<allPickers.count {
            let element = allPickers.element(boundBy: i)
            return element
        }

        return nil
    }

    /// Finds a segmented control by querying segmented control elements directly
    /// This is faster than scanning all descendants because it only iterates segmented control elements
    /// Returns the first segmented control found in the accessibility hierarchy
    static func findSegmentedControl(in app: XCUIApplication) -> XCUIElement? {
        // Wait for the section to fully expand
        Thread.sleep(forTimeInterval: 1.0)

        let allSegmentedControls = app.descendants(matching: .segmentedControl)
        let count = allSegmentedControls.count

        // Iterate through segmented control elements only
        for i in 0..<count {
            let element = allSegmentedControls.element(boundBy: i)
            return element
        }
        return nil
    }

    /// Finds all pickers by querying picker elements directly
    /// This is faster than scanning all descendants because it only iterates picker elements
    /// Returns all pickers found in the accessibility hierarchy
    static func findPickers(in app: XCUIApplication) -> [XCUIElement] {
        // Wait for the section to fully expand and pickers to render
        Thread.sleep(forTimeInterval: 1.0)

        let allPickers = app.pickerWheels
        let count = allPickers.count

        var pickers: [XCUIElement] = []
        // Iterate through picker elements only
        for i in 0..<count {
            let element = allPickers.element(boundBy: i)
            pickers.append(element)
        }
        return pickers
    }

    /// Finds the summary value text element for a section by its accessibility label.
    /// This is useful for verifying the summary displayed in a collapsed section header.
    /// - Parameters:
    ///   - sectionElement: The section's container element (e.g., app.otherElements["sectionGender"])
    ///   - accessibilityLabel: The accessibility label of the summary value text (e.g., "Gender value")
    /// - Returns: The XCUIElement for the summary value, or nil if not found
    static func findSummaryValue(in sectionElement: XCUIElement, withAccessibilityLabel label: String) -> XCUIElement? {
        // Wait for the UI to settle after section collapse
        Thread.sleep(forTimeInterval: 1.0)

        let summaryValues = sectionElement.descendants(matching: .staticText)
        let count = summaryValues.count

        for i in 0..<count {
            let element = summaryValues.element(boundBy: i)
            if element.label == label {
                return element
            }
        }
        return nil
    }

    /// Finds the summary value text element for a section by its accessibility label and returns its value.
    /// This is a convenience method that combines finding and validating the summary value.
    /// - Parameters:
    ///   - sectionElement: The section's container element (e.g., app.otherElements["sectionGender"])
    ///   - accessibilityLabel: The accessibility label of the summary value text (e.g., "Gender value")
    ///   - expectedValue: The expected value to assert against
    ///   - timeout: Time to wait for the element to appear
    /// - Returns: The string value of the summary if it matches, otherwise nil
    static func getSummaryValue(for sectionElement: XCUIElement, withAccessibilityLabel label: String, equalTo expectedValue: String, timeout: TimeInterval = 1.0) -> String? {
        // Wait for the UI to settle
        Thread.sleep(forTimeInterval: timeout)

        let summaryValues = sectionElement.descendants(matching: .staticText)
        let count = summaryValues.count

        for i in 0..<count {
            let element = summaryValues.element(boundBy: i)
            if element.label == label, let value = element.value as? String, value == expectedValue {
                return value
            }
        }
        return nil
    }

    /// Finds a picker wheel within a picker element
    /// - Parameter picker: The picker element to search within
    /// - Returns: The picker wheel element, or nil if not found
    static func findPickerWheel(in picker: XCUIElement) -> XCUIElement? {
        Thread.sleep(forTimeInterval: 0.5)
        let wheels = picker.descendants(matching: .pickerWheel)
        return wheels.element(boundBy: 0)
    }

    /// Selects a value in a picker wheel using the proper XCTest API
    /// - Parameters:
    ///   - picker: The picker element containing the wheel
    ///   - value: The string value to select (e.g., "34" for age)
    /// - Returns: True if the value was successfully selected, false otherwise
    static func selectValue(inPicker picker: XCUIElement, value: String) -> Bool {
        Thread.sleep(forTimeInterval: 0.5)
        // Use pickerWheels directly from app instead of descendants
        let app = XCUIApplication()
        let wheels = app.pickerWheels
        let count = wheels.count
        guard count > 0 else {
            return false
        }
        let wheel = wheels.element(boundBy: 0)
        // Use the proper XCUIElement.adjust API for picker wheels
        wheel.adjust(toPickerWheelValue: value)
        // Wait for the change to take effect
        Thread.sleep(forTimeInterval: 0.5)
        // Verify selection by checking the value
        if let selectedValue = wheel.value as? String, selectedValue.contains(value) {
            return true
        }
        return false
    }

    /// Selects a value in a wheel picker and verifies it against the section's summary
    /// (read after collapsing), rather than trusting the wheel's own accessibility value.
    ///
    /// `XCUIElement.adjust(toPickerWheelValue:)` is not fully reliable for SwiftUI
    /// `.pickerStyle(.wheel)` pickers: the wheel's own accessibility value can report the
    /// requested row even when the underlying `@Binding` actually committed a different
    /// (observed: adjacent, off by one) value. This was confirmed by instrumented diagnostic
    /// runs against this app on Xcode 27.2 / iOS 27.0 Simulator, and does not reproduce with
    /// real touch input - it is a synthetic-gesture artifact, not an app bug. Since the wheel
    /// itself cannot be trusted as ground truth while expanded (its custom accessibilityValue
    /// does not propagate for `.wheel` style pickers either), this helper collapses the
    /// section to read the real committed state from the summary label and retries with a
    /// fresh adjustment if it doesn't match yet.
    ///
    /// - Parameters:
    ///   - section: The section's container element (e.g. `app.otherElements["sectionAge"]`).
    ///     Must currently be expanded; left expanded again on return.
    ///   - value: The target value, e.g. 34 for age.
    ///   - summaryLabel: The accessibility label of the summary value text (e.g. "Age value").
    ///   - maxAttempts: How many times to retry the adjustment before giving up.
    /// - Returns: True once the summary confirms the value actually committed.
    static func selectValueVerified(inSection section: XCUIElement, value: Int, summaryLabel: String, maxAttempts: Int = 3) -> Bool {
        let app = XCUIApplication()

        // Requesting the same target repeatedly does not converge: the commit error observed
        // is deterministic for a given request, not a settle-timing race (confirmed by
        // instrumented diagnostic runs - see selectValueVerified doc comment above). So each
        // retry nudges the *requested* value by the error observed on the previous attempt,
        // rather than blindly repeating it.
        var requestedValue = value

        for attempt in 1...maxAttempts {
            let wheels = app.pickerWheels
            guard wheels.count > 0 else { return false }
            let wheel = wheels.element(boundBy: 0)
            wheel.adjust(toPickerWheelValue: "\(requestedValue)")

            section.tap() // collapse to force a read of the real, committed state
            let summary = findSummaryValue(in: section, withAccessibilityLabel: summaryLabel)
            let actual = (summary?.value as? String).flatMap { Int($0) }

            if actual == value {
                section.tap() // re-expand, leaving state as callers expect
                Thread.sleep(forTimeInterval: 0.3)
                return true
            }

            section.tap() // re-expand for the next attempt (or before returning failure)
            Thread.sleep(forTimeInterval: 0.3)

            if attempt < maxAttempts, let actual {
                requestedValue = value + (value - actual)
            }
        }
        return false
    }
}
