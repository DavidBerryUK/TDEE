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

    /// Finds a picker by scanning all elements
    /// Returns the first picker found in the accessibility hierarchy
    static func findPicker(in app: XCUIApplication) -> XCUIElement? {
        // Wait for the section to fully expand and picker to render
        Thread.sleep(forTimeInterval: 1.0)

        let allDescendants = app.descendants(matching: .any)
        let count = allDescendants.count

        // Iterate through all elements looking for pickers
        for i in 0..<count {
            let element = allDescendants.element(boundBy: i)
            if element.elementType == XCUIElement.ElementType.picker {
                return element
            }
        }
        return nil
    }

    /// Finds a picker by its position relative to a known element
    /// This avoids relying on accessibility identifiers which may not propagate correctly
    static func findPickerRelative(to sectionElement: XCUIElement, in app: XCUIApplication, afterDelay: TimeInterval = 0.5) -> XCUIElement? {
        // Wait for the section to expand
        Thread.sleep(forTimeInterval: afterDelay)

        let allDescendants = app.descendants(matching: .any)
        let sectionIndex = allDescendants.index(ofAccessibilityElement: sectionElement)

        if sectionIndex == NSNotFound {
            return nil
        }

        // Look for picker elements after the section header
        for i in (sectionIndex + 1)..<allDescendants.count {
            let element = allDescendants.element(boundBy: i)
            if element.elementType == XCUIElement.ElementType.picker {
                return element
            }
        }

        return nil
    }

    /// Finds a segmented control by scanning all elements
    /// Returns the first segmented control found in the accessibility hierarchy
    static func findSegmentedControl(in app: XCUIApplication) -> XCUIElement? {
        // Wait for the section to fully expand
        Thread.sleep(forTimeInterval: 1.0)

        let allDescendants = app.descendants(matching: .any)
        let count = allDescendants.count

        // Iterate through all elements looking for segmented controls
        for i in 0..<count {
            let element = allDescendants.element(boundBy: i)
            if element.elementType == XCUIElement.ElementType.segmentedControl {
                return element
            }
        }
        return nil
    }

    /// Finds all pickers by scanning all elements
    /// Returns all pickers found in the accessibility hierarchy
    static func findPickers(in app: XCUIApplication) -> [XCUIElement] {
        // Wait for the section to fully expand and pickers to render
        Thread.sleep(forTimeInterval: 1.0)

        let allDescendants = app.descendants(matching: .any)
        let count = allDescendants.count

        var pickers: [XCUIElement] = []
        // Iterate through all elements looking for pickers
        for i in 0..<count {
            let element = allDescendants.element(boundBy: i)
            if element.elementType == XCUIElement.ElementType.picker {
                pickers.append(element)
            }
        }
        return pickers
    }
}
