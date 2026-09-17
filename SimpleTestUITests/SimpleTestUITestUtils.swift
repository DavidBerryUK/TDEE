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
}
