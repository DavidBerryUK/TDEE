# Running UI Tests

## Quick Start

Run all UI tests on iPhone 17 Pro Max with iOS 27:

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTestUITests -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" test
```

## Running Individual Tests

To run a specific test class:

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTestUITests -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" test-without-codesign TESTFILTER=SimpleTestUITests_Age
```

To run a specific test method:

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTestUITests -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" test-without-codesign TESTFILTER=SimpleTestUITests_Age/testAgePickerExists
```

## Performance Notes

The tests use element scanning to find UI elements since `accessibilityIdentifier` doesn't reliably propagate from SwiftUI Picker views with `.pickerStyle(.wheel)` to XCUIElements.

**Current timing (approximate):**
- Test startup: ~5 seconds
- Per-section scanning: ~10-25 seconds (scanning 70-100 elements at ~0.3s each)
- Total test suite: ~2-3 minutes

**Bottleneck:** Each `element(boundBy:)` call takes ~0.3s due to the remote debugger protocol between Xcode and the simulator.

## Test Utility Functions

### `findPicker(in:)`
Scans all descendants to find the first picker element. Use when there's one picker per screen.

### `findSegmentedControl(in:)`
Scans all descendants to find the first segmented control.

### `findPickers(in:)`
Returns all picker elements found (useful when multiple pickers exist, like body fat integer/decimal).

### `waitForElement(_:)`
Waits for an element to exist with the given timeout. Returns `true` if found.

## Troubleshooting

### "simctl not found" error
Make sure you have the correct Xcode selected:
```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
```

### Tests find no elements
1. Check that sections are tapped before looking for elements
2. Wait for expansion animation (~0.3s)
3. The element scan will find elements but may be slow

### Slow tests
The scan is slow because each element lookup is a remote call. Consider:
- Reducing the number of elements to scan (use `children(matching:)` instead of `descendants(matching:)` when possible)
- Using `firstMatch` instead of `element(boundBy:)` where available
