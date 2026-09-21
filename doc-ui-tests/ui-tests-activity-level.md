# Activity Level UI Tests

## Quick Start

When developing or debugging a specific test, run only that test instead of all Activity Level tests:

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest

# Run only a specific test method
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" -skip-testing:"*" -only-testing:"SimpleTestUITests/SimpleTestUITests_ActivityLevel/testActivityLevelPickerExists" test
```

**Note:** For full test suite timing and other common commands, see [Running UI Tests](running-ui-tests.md).

## Overview

The Activity Level section allows users to select their activity level from a wheel picker. The section is part of the profile setup and affects TDEE (Total Daily Energy Expenditure) calculations.

## Test Coverage

The following test cases should be covered for Activity Level:

| Test Name | Description | Priority |
|-----------|-------------|----------|
| `testActivityLevelPickerExists` | Verifies the activity level wheel picker is accessible | High |
| `testActivityLevelSummaryUpdatesAfterSelectionChange` | Verifies collapsed section header updates with selected value | High |
| `testActivityLevelAllCases` | Verifies all 5 activity level cases are selectable | Medium |
| `testActivityLevelValuePersistsAfterCollapseExpand` | Verifies value is preserved when section is collapsed and re-expanded | Medium |

## Activity Level Cases

The `ActivityLevel` enum has 5 cases:

| Case | Display Name | Katch-McArdle Multiplier |
|------|--------------|--------------------------|
| `.sedentary` | "Sedentary (office job)" | 1.2 |
| `.lightExercise` | "Light Exercise (1-2 days)" | 1.375 |
| `.moderateExercise` | "Moderate Exercise (3-5 days)" | 1.55 |
| `.heavyExercise` | "Heavy Exercise (3-5 days)" | 1.725 |
| `.athlete` | "Athlete (2x per day)" | 1.9 |

## Accessibility Elements

| Element | Accessibility ID/Label | Notes |
|---------|----------------------|-------|
| Section container | `sectionActivityLevel` | Tappable to expand/collapse |
| Wheel picker | `.pickerWheel` (index 0) | Single picker in this section |
| Summary value | `"Activity level value"` | Static text showing selected level |

## Test Implementation Notes

### Picker Selection

Use `utils.selectValueVerified()` for selecting values. Activity Level has a single picker wheel at index 0.

```swift
let activitySection = app.otherElements["sectionActivityLevel"]
activitySection.tap()  // Expand section

// Select "Moderate Exercise" (index 2 in enum: sedentary=0, light=1, moderate=2)
let selected = utils.selectValueVerified(
    inSection: activitySection, 
    value: 2,  // ModerateExercise caseRawValue
    summaryLabel: "Activity level value",
    validRange: 0...4
)
```

### Value Verification

The summary text uses `.contentTransition(.interpolate)` for animation. Use `waitForStableValue()` to ensure the text has settled before reading:

```swift
let summary = utils.findSummaryValue(in: activitySection, withAccessibilityLabel: "Activity level value")
XCTAssertTrue(summary?.exists ?? false, "Activity level summary should exist")
let value = utils.waitForStableValue(of: summary!)
XCTAssertEqual(value, "Moderate Exercise")
```

**Note:** `findSummaryValue()` returns an optional `XCUIElement?`, so you must check `.exists` and force-unwrap (`!`) before passing to `waitForStableValue()`.

### Collapse/Expand Behavior

Collapsing and re-expanding the section rebuilds the editor view. This can sometimes cause the picker to drift to a different value. Use `collapseAndVerify()` to handle this:

```swift
// Select value while expanded
utils.selectValueVerified(inSection: activitySection, value: 3, ...)

// Collapse and verify it's preserved
let verified = utils.collapseAndVerify(
    inSection: activitySection, 
    value: 3, 
    summaryLabel: "Activity level value",
    validRange: 0...4
)
```

## Sample Test File

```swift
//
//  SimpleTestUITests_ActivityLevel.swift
//  SimpleTestUITests
//
//  Created by [Date]
//

import XCTest

final class SimpleTestUITests_ActivityLevel: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    /// Opens the Activity Level section and checks that the wheel picker shows up.
    @MainActor
    func testActivityLevelPickerExists() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        activitySection.tap()

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
        activitySection.tap()

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
        XCTAssertTrue(initialValue == "Sedentary" || initialValue == "Sedentary (office job)", 
                      "Initial value should be Sedentary, got '\(initialValue ?? "")'")

        // Test each case
        let cases: [(rawValue: Int, expected: String)] = [
            (0, "Sedentary"),
            (1, "Light Exercise"),
            (2, "Moderate Exercise"),
            (3, "Heavy Exercise"),
            (4, "Athlete")
        ]
        
        for (rawValue, expected) in cases {
            _ = utils.selectValueVerified(
                inSection: activitySection,
                value: rawValue,
                summaryLabel: "Activity level value",
                validRange: 0...4
            )
            
            // Collapse to verify summary
            activitySection.tap()
            let collapsedSummary = utils.findSummaryValue(in: activitySection, withAccessibilityLabel: "Activity level value")
            XCTAssertTrue(collapsedSummary?.exists ?? false, "Activity level summary should exist after collapsing")
            let collapsedValue = utils.waitForStableValue(of: collapsedSummary!)
            XCTAssertTrue(collapsedValue == expected, 
                          "Summary should show '\(expected)' for case \(rawValue), got '\(collapsedValue ?? "")'")
            
            // Re-expand for next iteration
            activitySection.tap()
        }
    }

    /// Verifies that the selected activity level persists when the section
    /// is collapsed and re-expanded.
    @MainActor
    func testActivityLevelValuePersistsAfterCollapseExpand() throws {
        let app = XCUIApplication()
        app.launch()

        let activitySection = app.otherElements["sectionActivityLevel"]
        activitySection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Activity level picker not found")
            return
        }

        // Select Athlete (case 4)
        XCTAssertTrue(utils.selectValueVerified(
            inSection: activitySection,
            value: 4,
            summaryLabel: "Activity level value",
            validRange: 0...4
        ), "Should be able to select Athlete")

        // Collapse and verify
        XCTAssertTrue(utils.collapseAndVerify(
            inSection: activitySection,
            value: 4,
            summaryLabel: "Activity level value",
            validRange: 0...4
        ), "Value should persist after collapse/expand")

        // Re-expand and verify in-editor value
        activitySection.tap()
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
        activitySection.tap()

        guard let picker = utils.findPicker(in: app) else {
            XCTFail("Activity level picker not found")
            return
        }

        // Start with default (Sedentary)
        XCTAssertTrue(utils.waitForElement(picker), "Picker should exist")

        // Select Light Exercise
        XCTAssertTrue(utils.selectValueVerified(
            inSection: activitySection,
            value: 1,
            summaryLabel: "Activity level value",
            validRange: 0...4
        ), "Should be able to select Light Exercise")

        // Collapse and verify
        activitySection.tap()
        let summary = utils.findSummaryValue(in: activitySection, withAccessibilityLabel: "Activity level value")
        XCTAssertTrue(summary?.exists ?? false, "Activity level summary should exist")
        let value = utils.waitForStableValue(of: summary!)
        XCTAssertTrue(value == "Light Exercise", "Summary should show 'Light Exercise', got '\(value ?? "")'")

        // Re-expand, select Heavy Exercise, collapse again
        activitySection.tap()
        XCTAssertTrue(utils.selectValueVerified(
            inSection: activitySection,
            value: 3,
            summaryLabel: "Activity level value",
            validRange: 0...4
        ), "Should be able to select Heavy Exercise")

        activitySection.tap()
        let summary2 = utils.findSummaryValue(in: activitySection, withAccessibilityLabel: "Activity level value")
        XCTAssertTrue(summary2?.exists ?? false, "Activity level summary should exist")
        let value2 = utils.waitForStableValue(of: summary2!)
        XCTAssertTrue(value2 == "Heavy Exercise", "Summary should show 'Heavy Exercise', got '\(value2 ?? "")'")
    }
}

```

## Running the Tests

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest

# Run all tests
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" test

# Run only Activity Level tests
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" -skip-testing:"*" -only-testing:"SimpleTestUITests/SimpleTestUITests_ActivityLevel" test
```
