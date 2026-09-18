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

        let allPickers = app.descendants(matching: .picker)
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

        let allPickers = app.descendants(matching: .picker)
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

        let allPickers = app.descendants(matching: .picker)
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
}
