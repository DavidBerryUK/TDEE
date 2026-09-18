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

    /// Minimum settle time before trusting a read of an animated summary value. SwiftUI's default
    /// `.easeInOut` (used by these summary Texts) is 0.35s, but a wheel picker's own deceleration
    /// after a large synthetic jump can still be coasting toward its final row well after that -
    /// the content-transition animation and the picker's physical settle are two different things,
    /// and only the slower of the two actually bounds how long a read can stay misleadingly
    /// "stable" (confirmed by instrumented diagnostic runs: a reading agreed with itself across
    /// multiple 50ms polls immediately after a multi-row jump, then changed again once the wheel's
    /// coast genuinely finished). This is deliberately generous rather than tightly tuned to the
    /// animation constant alone.
    private static let minimumSettleDuration: TimeInterval = 0.6

    /// Reads an element's accessibility value once it stops changing, rather than trusting the
    /// first read. Some summary text views (e.g. those using `.contentTransition(.numericText())`)
    /// animate their value change, and the accessibility value can briefly reflect an
    /// in-progress transition rather than the settled result - existence alone doesn't tell you
    /// the animation has finished, and neither does a short streak of matching reads: a value can
    /// plateau on a stale (or, worse, a coincidentally-target-matching) reading for a stretch that
    /// outlasts a couple of quick polls, especially once a caller has already retried a few times
    /// (confirmed by instrumented diagnostic runs - a retry's intermediate target briefly read
    /// back as "stable" before drifting further as the real animation caught up). So this waits
    /// out a minimum settle duration first, then polls for the read to agree with itself three
    /// times in a row as an extra safety margin, rather than trusting either signal alone.
    static func waitForStableValue(of element: XCUIElement, timeout: TimeInterval = 2.0, pollInterval: TimeInterval = 0.1) -> String? {
        Thread.sleep(forTimeInterval: minimumSettleDuration)

        var lastValue = element.value as? String
        var matchStreak = 0
        var elapsed: TimeInterval = minimumSettleDuration
        while elapsed < timeout {
            Thread.sleep(forTimeInterval: pollInterval)
            elapsed += pollInterval
            let current = element.value as? String
            if current == lastValue {
                matchStreak += 1
                if matchStreak >= 3 {
                    return current
                }
            } else {
                matchStreak = 0
            }
            lastValue = current
        }
        return lastValue
    }

    /// Selects a value in a wheel picker and verifies it against the section's summary text,
    /// rather than trusting the wheel's own accessibility value.
    ///
    /// `XCUIElement.adjust(toPickerWheelValue:)` is not fully reliable for SwiftUI
    /// `.pickerStyle(.wheel)` pickers: the wheel's own accessibility value can report the
    /// requested row even when the underlying `@Binding` actually committed a different
    /// (observed: adjacent, off by one) value. This was confirmed by instrumented diagnostic
    /// runs against this app on Xcode 27.2 / iOS 27.0 Simulator, and does not reproduce with
    /// real touch input - it is a synthetic-gesture artifact, not an app bug. Since the wheel
    /// itself cannot be trusted as ground truth (its custom accessibilityValue does not
    /// propagate for `.wheel` style pickers either), this helper reads the section's summary
    /// text instead and retries with a fresh adjustment if it doesn't match yet.
    ///
    /// The summary is read directly while the section stays expanded, without collapsing it
    /// first - earlier versions of this helper collapsed the section on the theory that only the
    /// collapsed summary reflected "real" state, but the summary text is part of the section's
    /// always-visible header row and reflects the model whether the section is expanded or not,
    /// so collapsing added no accuracy. It actively hurt: collapsing (and then re-expanding, to
    /// leave the UI as callers expect) tears down and rebuilds the whole editor view, and that
    /// fresh view's initial layout can itself land on a different row than the one it was
    /// initialized with - silently corrupting an already-confirmed value after the fact (observed
    /// on the Height picker, whose multi-unit editor is more expensive to rebuild than Age's;
    /// confirmed by instrumented diagnostic runs). Reading the always-live summary without ever
    /// tearing down the editor avoids that failure mode entirely, and is faster besides.
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
    ///     Must currently be expanded, and is left expanded on return.
    ///   - value: The target value, e.g. 34 for age.
    ///   - summaryLabel: The accessibility label of the summary value text (e.g. "Age value").
    ///   - validRange: The picker's full range of selectable values (e.g. 16...99 for age).
    ///     Retry corrections are clamped to this range so a boundary value (e.g. the max) can't
    ///     be nudged past the picker's actual limits, which `adjust(toPickerWheelValue:)`
    ///     treats as a hard failure rather than a normal mismatch.
    ///   - wheelIndex: Which of `app.pickerWheels` to drive. Height's editor keeps all three
    ///     unit variants (cm/inches/feet+inches) mounted at once behind a ZStack, so more than
    ///     one `.pickerWheel` element can exist simultaneously even though only one is visible -
    ///     index 0 is the centimeters wheel, matching its position in the view's source order
    ///     (accessibility identifiers set directly on those pickers don't propagate to the
    ///     underlying `.pickerWheel` element, the same gap documented above, so position is the
    ///     only thing that reliably distinguishes them). Age and Gender only ever have one
    ///     picker wheel on screen, so the default of 0 is correct for them unchanged.
    ///   - maxAttempts: How many times to retry the adjustment before giving up.
    /// - Returns: True once the summary confirms the value actually committed.
    static func selectValueVerified(inSection section: XCUIElement, value: Int, summaryLabel: String, validRange: ClosedRange<Int>, wheelIndex: Int = 0, maxAttempts: Int = 3) -> Bool {
        let app = XCUIApplication()

        // Requesting the same target repeatedly does not converge: the commit error observed
        // is deterministic for a given request, not a settle-timing race (confirmed by
        // instrumented diagnostic runs - see doc comment above). So each retry nudges the
        // *requested* value by the error observed on the previous attempt, rather than
        // blindly repeating it.
        var requestedValue = value

        for attempt in 1...maxAttempts {
            let wheels = app.pickerWheels
            guard wheels.element(boundBy: wheelIndex).waitForExistence(timeout: 2.0) else { return false }
            let wheel = wheels.element(boundBy: wheelIndex)
            wheel.adjust(toPickerWheelValue: "\(requestedValue)")

            let summary = findSummaryValue(in: section, withAccessibilityLabel: summaryLabel)
            let actual = summary.flatMap { waitForStableValue(of: $0) }.flatMap { Int($0) }

            if actual == value {
                return true
            }

            if attempt < maxAttempts, let actual {
                let corrected = value + (value - actual)
                requestedValue = min(max(corrected, validRange.lowerBound), validRange.upperBound)
            }
        }
        return false
    }

    /// Collapses a section already showing `value` (e.g. via `selectValueVerified`) and confirms
    /// the summary still shows it once collapsed - retrying the whole selection with a nudged
    /// target if collapsing itself changed the value.
    ///
    /// Collapsing tears down and rebuilds the section's editor view (see `selectValueVerified`'s
    /// doc comment on why that view teardown isn't a no-op), and that can commit a different row
    /// than the one already confirmed while expanded. Unlike the `adjust` off-by-one, this is not
    /// a settle-timing issue - a wrong reading here does not self-correct no matter how long you
    /// wait afterward (confirmed by instrumented diagnostic runs: polled once every 0.2s for 4
    /// full seconds, stayed on the same wrong value throughout). So the fix is the same kind of
    /// nudge-and-retry `selectValueVerified` already uses, just triggered by collapsing rather
    /// than by `adjust`.
    ///
    /// - Parameters:
    ///   - section: Must currently be expanded and already showing `value`. Left collapsed on
    ///     success; left expanded if it gives up after `maxAttempts`.
    ///   - value: The value that should still be selected after collapsing.
    ///   - summaryLabel: The accessibility label of the summary value text (e.g. "Age value").
    ///   - validRange: Forwarded to the retry's `selectValueVerified` call.
    ///   - wheelIndex: Forwarded to the retry's `selectValueVerified` call.
    ///   - maxAttempts: How many times to retry (collapse, check, and if needed re-select) before
    ///     giving up.
    /// - Returns: True once the collapsed summary confirms `value`.
    static func collapseAndVerify(inSection section: XCUIElement, value: Int, summaryLabel: String, validRange: ClosedRange<Int>, wheelIndex: Int = 0, maxAttempts: Int = 3) -> Bool {
        for attempt in 1...maxAttempts {
            section.tap() // collapse

            let summary = findSummaryValue(in: section, withAccessibilityLabel: summaryLabel)
            let actual = summary.flatMap { waitForStableValue(of: $0) }.flatMap { Int($0) }

            if actual == value {
                return true
            }

            guard attempt < maxAttempts, let actual else { return false }

            section.tap() // re-expand so the retry below can drive the wheel again
            let corrected = value + (value - actual)
            let clamped = min(max(corrected, validRange.lowerBound), validRange.upperBound)
            guard selectValueVerified(inSection: section, value: clamped, summaryLabel: summaryLabel, validRange: validRange, wheelIndex: wheelIndex) else {
                return false
            }
        }
        return false
    }

    /// Runs `steps`, checks the section's summary against `expected`, and if it doesn't match,
    /// calls `recover` (with the wrong value that was actually read) and tries `steps` again - up
    /// to `maxAttempts` times.
    ///
    /// For actions with no direct wheel to nudge (e.g. switching Height's unit-of-measure, which
    /// only reads an already-committed value through a conversion, rather than adjusting a wheel
    /// toward a target) `selectValueVerified`/`collapseAndVerify`'s nudge-by-the-observed-error
    /// correction doesn't directly apply - there's no wheel row to nudge. But the underlying bug
    /// is the same collapse-triggered class `collapseAndVerify` corrects for (see its doc
    /// comment), and it is just as deterministic here: retrying the identical `steps` reproduces
    /// the identical wrong reading rather than settling on the right one eventually, so `recover`
    /// is given the actual (wrong) value read, so a caller that does have some indirect way to
    /// nudge the outcome - e.g. Height re-selecting a different centimeters value - can compute a
    /// real correction instead of blindly repeating the same steps.
    ///
    /// - Parameters:
    ///   - section: The section the summary belongs to.
    ///   - expected: The exact string the summary should show once `steps` completes.
    ///   - summaryLabel: The accessibility label of the summary value text to check.
    ///   - maxAttempts: How many times to retry `steps` before giving up.
    ///   - steps: Performs the action under test; must leave the section in a state where
    ///     `summaryLabel` reflects the outcome (typically collapsed).
    ///   - recover: Runs only between failed attempts, before `steps` runs again, with whatever
    ///     wrong value was actually read (nil if the summary couldn't be read at all) - typically
    ///     re-expanding and nudging whatever `steps` changed so the next attempt starts closer to
    ///     the target.
    /// - Returns: True once the summary matches `expected`.
    static func verifyWithRetry(inSection section: XCUIElement, expected: String, summaryLabel: String, maxAttempts: Int = 3, steps: () -> Void, recover: (String?) -> Void) -> Bool {
        for attempt in 1...maxAttempts {
            steps()

            let summary = findSummaryValue(in: section, withAccessibilityLabel: summaryLabel)
            let actual = summary.flatMap { waitForStableValue(of: $0) }

            if actual == expected {
                return true
            }

            guard attempt < maxAttempts else { return false }
            recover(actual)
        }
        return false
    }
}
