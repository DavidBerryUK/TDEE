//
//  SimpleTestUITestUtils.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

class SimpleTestUITestUtils {

    // MARK: - Helper Methods

    /// Waits for an element to exist, polling rather than sleeping a fixed duration.
    static func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 2.0) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }

    /// Finds the first picker wheel in the accessibility hierarchy, waiting for it to appear.
    static func findPicker(in app: XCUIApplication, timeout: TimeInterval = 2.0) -> XCUIElement? {
        let picker = app.pickerWheels.firstMatch
        return picker.waitForExistence(timeout: timeout) ? picker : nil
    }

    /// Finds the first segmented control in the accessibility hierarchy, waiting for it to appear.
    static func findSegmentedControl(in app: XCUIApplication, timeout: TimeInterval = 2.0) -> XCUIElement? {
        let control = app.descendants(matching: .segmentedControl).firstMatch
        return control.waitForExistence(timeout: timeout) ? control : nil
    }

    /// Finds all picker wheels currently in the accessibility hierarchy, waiting for at least one
    /// to appear.
    static func findPickers(in app: XCUIApplication, timeout: TimeInterval = 2.0) -> [XCUIElement] {
        guard app.pickerWheels.firstMatch.waitForExistence(timeout: timeout) else { return [] }
        let count = app.pickerWheels.count
        return (0..<count).map { app.pickerWheels.element(boundBy: $0) }
    }

    /// Finds the summary value text element for a section by its accessibility label, waiting for
    /// it to appear.
    /// - Parameters:
    ///   - sectionElement: The section's container element (e.g., app.otherElements["sectionGender"])
    ///   - label: The accessibility label of the summary value text (e.g., "Gender value")
    /// - Returns: The XCUIElement for the summary value, or nil if not found
    static func findSummaryValue(in sectionElement: XCUIElement, withAccessibilityLabel label: String, timeout: TimeInterval = 2.0) -> XCUIElement? {
        let element = sectionElement.descendants(matching: .staticText)
            .matching(NSPredicate(format: "label == %@", label))
            .firstMatch
        return element.waitForExistence(timeout: timeout) ? element : nil
    }

    /// Reads an element's accessibility value once it stops changing, rather than trusting the
    /// first read. Some summary text views (e.g. those using `.contentTransition(.numericText())`)
    /// animate their value change, and the accessibility value can briefly reflect an
    /// in-progress transition rather than the settled result - existence alone doesn't tell you
    /// the animation has finished. Polls in short bursts and returns as soon as the read agrees
    /// with the previous one twice in a row, instead of waiting a fixed worst-case duration. A
    /// single repeat isn't enough: the value can sit on the pre-change reading for a couple of
    /// poll cycles before the transition's completion actually commits it, so requiring two
    /// repeats guards against mistaking that plateau for the settled value.
    static func waitForStableValue(of element: XCUIElement, timeout: TimeInterval = 2.0, pollInterval: TimeInterval = 0.05) -> String? {
        var lastValue = element.value as? String
        var matchStreak = 0
        var elapsed: TimeInterval = 0
        while elapsed < timeout {
            Thread.sleep(forTimeInterval: pollInterval)
            elapsed += pollInterval
            let current = element.value as? String
            if current == lastValue {
                matchStreak += 1
                if matchStreak >= 2 {
                    return current
                }
            } else {
                matchStreak = 0
            }
            lastValue = current
        }
        return lastValue
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
    /// The summary text animates its value via `.contentTransition(.numericText())`, so it's read
    /// with `waitForStableValue` rather than trusted on first read - otherwise a read can land
    /// mid-transition and see neither the old nor the new value.
    ///
    /// The picker's very last row is a harder case than a normal off-by-one: `adjust` leaves the
    /// wheel's own `.value` reporting the requested (last) row while the `@Binding` never
    /// actually commits, so retrying with the same target is a no-op forever - the wheel already
    /// believes it's there. There's no in-range value to nudge the request to past the maximum,
    /// so this can legitimately fail to converge at the picker's upper bound; callers verifying
    /// the exact last value should account for that instead of treating it as a normal retry
    /// budget problem (confirmed by instrumented diagnostic runs against this app on Xcode 27.2 /
    /// iOS 27.0 Simulator - the first row does not exhibit this).
    ///
    /// - Parameters:
    ///   - section: The section's container element (e.g. `app.otherElements["sectionAge"]`).
    ///     Must currently be expanded; left expanded again on return.
    ///   - value: The target value, e.g. 34 for age.
    ///   - summaryLabel: The accessibility label of the summary value text (e.g. "Age value").
    ///   - validRange: The picker's full range of selectable values (e.g. 16...99 for age).
    ///     Retry corrections are clamped to this range so a boundary value (e.g. the max) can't
    ///     be nudged past the picker's actual limits, which `adjust(toPickerWheelValue:)`
    ///     treats as a hard failure rather than a normal mismatch.
    ///   - maxAttempts: How many times to retry the adjustment before giving up.
    /// - Returns: True once the summary confirms the value actually committed.
    static func selectValueVerified(inSection section: XCUIElement, value: Int, summaryLabel: String, validRange: ClosedRange<Int>, maxAttempts: Int = 3) -> Bool {
        let app = XCUIApplication()

        // Requesting the same target repeatedly does not converge: the commit error observed
        // is deterministic for a given request, not a settle-timing race (confirmed by
        // instrumented diagnostic runs - see doc comment above). So each retry nudges the
        // *requested* value by the error observed on the previous attempt, rather than
        // blindly repeating it.
        var requestedValue = value

        for attempt in 1...maxAttempts {
            let wheel = app.pickerWheels.firstMatch
            guard wheel.waitForExistence(timeout: 2.0) else { return false }
            wheel.adjust(toPickerWheelValue: "\(requestedValue)")

            section.tap() // collapse to force a read of the real, committed state
            let summary = findSummaryValue(in: section, withAccessibilityLabel: summaryLabel)
            let actual = summary.flatMap { waitForStableValue(of: $0) }.flatMap { Int($0) }

            if actual == value {
                section.tap() // re-expand, leaving state as callers expect
                return true
            }

            section.tap() // re-expand for the next attempt (or before returning failure)

            if attempt < maxAttempts, let actual {
                let corrected = value + (value - actual)
                requestedValue = min(max(corrected, validRange.lowerBound), validRange.upperBound)
            }
        }
        return false
    }
}
