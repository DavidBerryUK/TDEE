# UI Testing Guide

> ## ⚠️ HISTORICAL - THE UI TEST SUITE WAS REMOVED ON 2026-09-22
>
> `SimpleTestUITests/` and its Xcode target no longer exist. **Nothing in this document describes
> the current state of the project.** It is kept only as a record of what was learned about
> XCUITest and SwiftUI accessibility, because most of it is undocumented by Apple and was expensive
> to discover.
>
> **Why it was removed.** The suite cost roughly a week of effort to get to 31/32 passing. The
> value did not justify that: every defect the suite ever caught was a defect *in the tests
> themselves*, not in the app. The final session fixed three such bugs - two missing `app.launch()`
> calls and one section left collapsed before a lookup - and found zero app bugs.
>
> **To recover the tests**, they are intact in git:
> ```bash
> git show e6845db --stat                       # the commit holding the full 31/32 suite
> git checkout e6845db -- SimpleTestUITests/    # restore the test sources
> ```
> Note the Xcode *target* was removed from `project.pbxproj` separately, so restoring the sources
> alone will not rebuild the target - recreate it in Xcode, or revert the deletion commit.
>
> **What remains:** the `SimpleTestTests/` unit test target (10 tests, all passing, runs in
> seconds without a simulator). That tier never caused any of the pain described below - it needs
> no accessibility tree, no `setSection`, no synthetic gestures, and does not flake.
>
> **The one piece of app code that existed purely for these tests has also been removed:** the
> chevron in `UILayoutSectionView` no longer carries `.accessibilityIdentifier("<id>.disclosure")`,
> `.accessibilityValue("expanded"/"collapsed")` or `.accessibilityAddTraits(.isButton)`. Everything
> below that refers to reading section state from the disclosure button is therefore obsolete.
> (Trade-off worth knowing: VoiceOver no longer announces whether a section is open.)

Everything needed to create, run, and debug UI tests for the SimpleTest app: environment setup,
the create/run/iterate workflow, the utility function reference, and — critically — the checklist
of environment and code traps that have repeatedly caused hours-long "the simulator is hanging /
tests won't pass" sessions. Read the **Before You Start Debugging Simulator Issues** section
first if tests are failing or hanging in a way that doesn't make sense; most of the time the real
cause isn't the simulator at all.

---

## Before You Start Debugging "Simulator" Issues

If a UI test session is going in circles — hangs, flaky failures, "the simulator seems broken" —
**check these in order before touching simulator state at all**. In the session that produced this
guide, what looked like a simulator/clone/reset problem was actually an ambiguous destination and
two silent compile errors; the simulator infrastructure (parallel clones, per-test app reset) was
never broken.

### 1. Check for duplicate simulator names

```bash
xcrun simctl list devices | grep "iPhone 17 Pro Max"
```

**On this machine there are currently two devices named `iPhone 17 Pro Max`**, but they are on
*different* runtimes (iOS 26.5 and iOS 27.0), so `OS=27.0` disambiguates them. Prefer the UDID
anyway - `id=4CF378DE-00AB-4BB9-BF60-A83B83C6574F` is the iOS 27.0 one.

If more than one device with the **same name and OS version** exists, any
`-destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0"` invocation fails
immediately with "Unable to find a device matching the provided destination specifier... multiple
devices matched". Depending on how the failure is handled upstream, this can look like a hang or
an inexplicable test failure rather than the clear destination error it actually is.

**Fix:** delete the extra device (check `xcrun simctl list pairs` / `xcrun simctl listapps` first
to confirm which one is safe to remove — e.g. one paired with a watch, or one with the app already
installed, may be the "real" one to keep):

```bash
xcrun simctl delete <UDID-of-the-extra-one>
```

Or, permanently sidestep the issue by targeting a specific device by UDID instead of by name:

```bash
xcodebuild ... -destination "platform=iOS Simulator,id=<UDID>" ...
```

### 2. Confirm the test target actually builds

**Do this before running any test.** A build failure in the test target can be mistaken for a
simulator problem, especially if the failure happens deep in a parallelized/cloned test run.

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug \
  -destination "platform=iOS Simulator,id=<UDID>" build-for-testing
```

Look for `** TEST BUILD SUCCEEDED **` vs `** TEST BUILD FAILED **`. If it fails, fix the compile
errors (see the Swift/iOS gotchas below for the two that have bitten this project already) before
attempting a test run at all. Running `test` instead of `build-for-testing` will also build first,
but `build-for-testing` alone is faster to iterate on and keeps build errors clearly separated from
runtime/test failures.

### 3. Only then suspect the simulator/environment

Once the build genuinely succeeds and a real test run still hangs or misbehaves, move on to the
"Simulator Cleanup" and "Xcode Version Handling" sections below.

---

## Swift/iOS Compile Gotchas Specific to This Project

These have caused real, silent build failures in `SimpleTestUITests`. `build-for-testing` (above)
catches all of them immediately — the mistake to avoid is assuming a build failure is a simulator
issue instead of reading the compiler error.

### `MemberImportVisibility` means `import XCTest` no longer gives you Foundation for free

This project's build settings enable the Swift upcoming feature `MemberImportVisibility`
(visible in the `xcodebuild` invocation's `-enable-upcoming-feature MemberImportVisibility` flag).
Under this feature, symbols from a module that's only imported *transitively* (e.g. Foundation via
`import XCTest`) are no longer visible. Using `NSPredicate`, `URL`, `TimeInterval`, etc. in a file
that only has `import XCTest` can fail with `cannot find 'X' in scope` even though it compiled
before. **Fix:** add `import Foundation` explicitly to any UI test file that uses Foundation types
directly.

### `Process` (`NSTask`) does not exist on iOS

`Foundation.Process` is a **macOS-only** API — it is unavailable on iOS/iOS Simulator entirely,
regardless of imports. A UI test bundle runs *on the simulated device*, not on the Mac host, so it
cannot shell out to `xcrun simctl` or any other host command via `Process`. Any helper that tries
this (e.g. an "uninstall the app via `simctl`" reset helper) will fail to compile with
`cannot find 'Process' in scope`, not just fail at runtime. If you need host-side control of the
simulator (uninstalling the app, resetting state, etc.), that has to happen from the driving shell
script/CI step *outside* the XCTest process, not from inside a test.

### A missing variable declaration silently blocks the whole test target

`SimpleTestUITests_Age.swift`'s `testAgeSummaryUpdatesAfterSelectionChange()` once referenced `app`
without declaring `let app = XCUIApplication(); app.launch()` first (every other test method in the
file had it). This is an ordinary compile error, but because Swift compiles the whole target as one
job, it can make the *entire* `SimpleTestUITests` bundle fail to build, so no test in the target
runs at all — again easy to misattribute to "the simulator won't cooperate" rather than "one method
doesn't compile."

**Pattern to check when a new test method is added:** every `@MainActor func testX() throws`
should start with either `let app = XCUIApplication(); app.launch()`, or clearly reuse an `app`
already in scope (e.g. inside a `measure` closure). A quick sanity grep:

```bash
grep -L "let app = XCUIApplication" SimpleTestUITests/SimpleTestUITests_*.swift
```
(then manually check any hits aren't legitimately scoped some other way, like `testLaunchPerformance()`).

---

## Check These Two Things Before Any Deep Investigation

A 2026-09-22 debugging session lost hours to an elaborate crash theory - crash reports, SIGTERM
traces, live `log stream` capture - when the real cause was a missing `app.launch()` that the
grep below would have found in two seconds. **This guide already documented that failure class**
(see "A missing variable declaration..." below) and the diagnostic still did not start there.
Start here.

### 1. Does every test method launch the app?

```bash
cd /Users/davidberry/sources/ios/SimpleTest
for f in SimpleTestUITests/SimpleTestUITests_*.swift; do
  echo "$f: $(grep -c 'app.launch()' "$f") launches / $(grep -c 'func test' "$f") tests"
done
```

Every test method needs its own `app.launch()`. `let app = XCUIApplication()` alone only creates a
*proxy* - it does not start anything.

**A test missing `launch()` can still pass**, which is what makes this so hard to spot.
`tearDownWithError` calls `utils.resetAppState()`, which launches the app, so any test that runs
*after* another test in the same class - or on the same parallel clone - inherits a running app
and passes. Only the first test to run on a clone fails. That is why
`SimpleTestUITests_BodyFat.testBodyFatMethodSelectorExists()` failed while
`testCanSelectManualBodyFatEntry()` passed, despite both having the same defect.

**The symptom is misleading.** With no app running you get
`Failed to get matching snapshot: Application DaveBerryUk.SimpleTest is not running`, or a
`setSection` returning false ("Section should expand") because `waitForExistence` never resolves.
Neither error mentions launching. There is **no crash report on disk** - confirm with
`find ~/Library/Logs/DiagnosticReports -iname "*SimpleTest*"` before chasing a crash, and note
that the SIGTERM visible in `log stream` is just normal teardown, not the cause.

### 2. Is the section actually expanded at the point of the lookup?

A collapsed section does not merely hide its editor - `UILayoutSectionView` is
`if isExpanded { editorView() }`, so the editor and everything inside it is **absent from the
tree entirely**. Any lookup of a wheel or segmented control while collapsed fails with
`No segmented control '<id>'. Is the section expanded?`.

The trap is a *helper that changes state as a side effect*. `verifyWithRetry`'s `steps` closure
in the Height and Weight unit-of-measure tests ends by collapsing the section. When it succeeds
without needing a recovery pass, it leaves the section **collapsed** - and the code immediately
after it looked up the unit selector without re-expanding. When a recovery pass *was* needed, the
`recover` closure re-expanded the section and the same code worked. Hence the same test failing
with two different messages on different runs.

**Rule:** never let a block inherit whatever state the previous block happened to leave. State the
precondition. `setSection` is idempotent, so an unconditional
`XCTAssertTrue(utils.setSection("sectionX", open: true, in: app))` before a lookup costs nothing
and removes the whole class of failure.

---

## App-Code Bugs That Look Like Test Bugs

Not every UI test failure is a test bug. Two classes worth checking in the app code itself before
assuming the test is wrong:

### Missing `.accessibilityValue`

Every "section summary" view in this app (`UISectionSummaryValueAge`, `UISectionSummaryValueWeight`,
etc.) should set **both**:
```swift
.accessibilityLabel("X value")      // used to *find* the element
.accessibilityValue("\(actualValue)") // used to *read* the element's content
```
If only `.accessibilityLabel` is set, `element.value` reads back empty/nil in XCUITest (and for any
real assistive technology too) even though the label lookup succeeds and the text renders visibly
on screen. `UISectionSummaryValueActivityLevel` had exactly this bug — found because
`waitForStableValue` kept returning `''` for a value that was visibly correct on screen. When a
summary read comes back empty despite the element existing, check the view's modifiers for a
missing `.accessibilityValue` before assuming a test-side timing issue.

### Never toggle a section - set it to the state you want, and check first

**This is the single most important rule in this document.** It replaces the old
"tap the chevron instead of the section" advice, which was necessary but not sufficient.

Every section now publishes its own open/closed state, so a test never has to *assume* what state
the UI is in. Before tapping, decide whether you are trying to **open** or **close**, read the
section's current state, and tap only if the two differ.

```swift
@discardableResult
private func setSection(open: Bool, maxAttempts: Int = 3) -> Bool {
    let chevron = XCUIApplication().buttons["sectionActivityLevel.disclosure"]
    guard chevron.waitForExistence(timeout: 5.0) else {
        XCTFail("Activity Level disclosure button not found")
        return false
    }
    let target = open ? "expanded" : "collapsed"

    for _ in 1...maxAttempts {
        if chevron.value as? String == target { return true }   // already there - do nothing
        chevron.tap()
        var elapsed: TimeInterval = 0
        while elapsed < 5.0 {                                    // wait for the UI to confirm
            if chevron.value as? String == target { return true }
            Thread.sleep(forTimeInterval: 0.05)
            elapsed += 0.05
        }
    }
    XCTFail("Section did not reach '\(target)'")
    return false
}
```

Call sites state their intent instead of flipping a switch:

```swift
setSection(open: true)    // NOT: toggleSection(section)
setSection(open: false)
```

**Why this matters more than it looks.** The old `toggleSection` helper tapped unconditionally.
Every call site documented its intent in a *comment* - `// collapse`, `// re-expand`,
`// Tap to expand` - but the intent existed only in the comment, never in the code. So if the
section was not in the state the test assumed, the tap flipped it the wrong way and the test
carried on into a failure that surfaced several assertions later, far from the cause.

With an intent-driven setter:

- **A wrong assumption becomes a no-op** instead of an inverted state.
- **A missed tap is retried** instead of silently corrupting a picker value. This is what kills
  the old "value reverts to the default after collapse" bug at the root: if a tap lands in the
  picker rather than the header, the state simply does not change, so the helper taps again
  rather than letting a stray wheel adjustment through.
- **No sleeps are needed.** The helper waits for the state to actually change, so
  `sleep(1) // allow animation to complete` disappears from call sites.
- **Teardown gets simpler.** `setSection(open: false)` is safe to call unconditionally; there is
  no need to probe for a visible picker wheel first to guess whether the section is open.

#### The state lives on the disclosure button

`UILayoutSectionView` puts the state on the chevron:

```swift
Image(systemName: "chevron.down")
    .accessibilityIdentifier(accessibilityId.map { "\($0).disclosure" } ?? "")
    .accessibilityLabel("\(title) section")
    .accessibilityValue(isExpanded ? "expanded" : "collapsed")
    .accessibilityAddTraits(.isButton)
```

Two things follow:

1. **It is a `button`, not an `image`.** `.accessibilityAddTraits(.isButton)` determines the
   XCUIElement type. `section.images["chevron.down"]` finds **nothing**. Use
   `app.buttons["<sectionId>.disclosure"]`.
2. **The value is the state.** `chevron.value as? String` is `"expanded"` or `"collapsed"`.

This is also correct accessibility behaviour - a VoiceOver user now hears whether a disclosure is
open - so it is not test-only scaffolding. Note there is **no native `isExpanded` trait** in
SwiftUI (checked against the iOS 27 SDK: `AccessibilityTraits` has `isButton`, `isHeader`,
`isSelected`, `isToggle` and others, but nothing for expansion), which is why the state is carried
as an `accessibilityValue`.

#### Still never tap the section container

`XCUIElement.tap()` taps the geometric centre of the element's frame. A section's outer identifier
covers the header *and*, once expanded, the whole editor beneath it. For a tall editor the centre
lands well inside the picker, so `section.tap()` performs an unwanted wheel adjustment instead of
collapsing. Tap the disclosure button, always. Do not write a `section.tap()` fallback for when
the button is not found - that fallback is the bug.

### The control identifier reference

Verified against the live accessibility tree on Xcode 27.2 / iOS 27.0 Simulator. Every wheel
resolves to **exactly one** `pickerWheel`; every segmented control resolves directly.

| Section | Section id | Wheels (`app.pickers[...]`) | Segmented control (`app.segmentedControls[...]`) |
|---|---|---|---|
| Age | `sectionAge` | `agePicker` | — |
| Gender | `sectionGender` | — | `Gender` |
| Height | `sectionHeight` | `heightCmWheel`, `heightInchesWheel`, `heightFeetWheel`, `heightFeetInchesWheel` | `heightUnitSelector` |
| Weight | `sectionWeight` | `weightKgWheel`, `weightPoundsWheel`, `weightStonesWheel`, `weightStonesPoundsWheel` | `weightUnitSelector` |
| Activity Level | `sectionActivityLevel` | `activityLevelPicker` | — |
| Body Fat | `sectionBodyFatPercentage` | `bodyFatPicker`, `bodyFatDecimalPicker` | `bodyFatMethodSegmentedControl` |

Three things to know about this table:

- **`sectionMacroSplit` and `sectionCalorieAdjustment` are not on the main screen.** They resolve
  to nothing - no container, no disclosure button. Do not include them in a "collapse everything"
  loop.
- **The Body Fat wheels only exist when Manual Entry is selected.** The method segments are
  exactly `Omit`, `Estimate`, `Manual Entry`.
- **Height and Weight keep every unit variant mounted at once**, so `app.pickerWheels.count` is 4
  when either is expanded. That is why the wheels are named individually - you never index into
  that list. (`.accessibilityHidden(!show)` on the inactive variants was tried and had **no
  effect**: all four stayed in the tree and reported `isHittable == true`. This remains a genuine
  accessibility bug - a VoiceOver user can reach invisible pickers - but it does not affect tests.)

### Reading output from inside a UI test

`print()` from a UI test goes nowhere useful. It is captured **neither** by `xcodebuild`'s console
output **nor** by `xcrun xcresulttool get test-results activities`. To get diagnostics out of a
test, put them in an `XCTFail` message (which appears in `failureText`) or attach them:

```swift
let a = XCTAttachment(string: app.debugDescription)
a.name = "tree"; a.lifetime = .keepAlways; add(a)
```

Then read them with:

```bash
xcrun xcresulttool get test-results summary --path <bundle>.xcresult
```

### Picker rows aren't always simple integers

`selectValueVerified` / `collapseAndVerify` in `SimpleTestUITestUtils` assume the picker wheel's
rows are stringified integers (`"34"`, `"99"`, ...) — that's true for Age/Height/Weight, but **not**
for enum-backed pickers like Activity Level, whose wheel rows are full display strings (e.g.
`"Sedentary (office job)"`) while the section summary shows a different, shorter string (e.g.
`"Sedentary"`). Passing an `Int` value to these helpers for such a picker fails immediately with
`Requested adjust to value 'N' which is not one of the possible values ...`. For string-valued
pickers, write a small local equivalent that calls `wheel.adjust(toPickerWheelValue: fullRowText)`
and verifies the summary against the *short* text — see `SimpleTestUITests_ActivityLevel.swift`'s
`selectActivityLevel`/`collapseAndVerifyActivityLevel` for the pattern to copy.

---

## ⚠️ Important: Simulator Cleanup

**Run tests on a fresh simulator** - tests can leave the simulator in a broken state:

```bash
# Kill all existing simulators before running tests
xcrun simctl shutdown all

# Run tests
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" test
```

**Why:** UI tests can leave the simulator in a hung state after execution, causing the test runner
to wait 10+ minutes waiting for diagnostics that never arrive. Also check for **duplicate simulator
names** (see above) before assuming a hang is state corruption rather than an ambiguous destination.

---

## ⚠️ Important: Progress Communication

**When long-running operations are executing, you will see status updates at key stages.** This is
non-negotiable - always inform the user what is happening:

1. **Test suite runs (3-5 minutes)** - Status is shown per-test and per-assertion
2. **Simulator launches** - Notification when simulator is starting/ready
3. **Build operations** - Build phase notifications (compiling, linking, testing)
4. **Iterations** - Each retry cycle is announced with the attempt number

**If you don't see status updates for more than 5 minutes, the process may be stuck.** When running
a full suite in the background, don't rely on the invoking shell's own return to mean the test run
finished — double-backgrounding (e.g. trailing `&` on a command *also* run via a backgrounding
mechanism) can make the outer wrapper report "done" while the actual `xcodebuild` process is still
running, or gets killed early when its parent shell exits. Confirm actual completion by checking
for the process directly (`ps -p <PID>`) or waiting on it explicitly, not just on the first
"completed" signal.

## ⚡ Timing Notes and Optimization

### Test Execution Timing

**Important:** Tests run much faster than AI response times. The actual test execution is quick:
- **Test startup:** ~5 seconds (after simulator is ready)
- **Per-section scanning:** ~10-25 seconds (scanning 70-100 elements)
- **Actual test execution:** Tests themselves run rapidly once started

The bottleneck is typically the AI iteration loop, not the tests themselves.

### Optimizing the Development Process

To maximize efficiency when creating/debugging tests:

1. **Run individual tests** - Use `-only-testing:` to target specific test methods
2. **Reuse simulators** - Don't shut down simulators between test runs
3. **Batch assertions** - Group related assertions in single test runs
4. **Read logs efficiently** - Focus on the final summary first, then drill into failures
5. **Prefer the xcresult summary over grepping raw logs** - `xcodebuild`'s console log doesn't
   always print a clean "Executed N tests" line, especially with `-collect-test-diagnostics never`.
   Get precise pass/fail counts and failure text from the result bundle instead:
   ```bash
   xcrun xcresulttool get test-results summary --path <path-to>.xcresult
   ```
   The `.xcresult` path is printed near the end of the `xcodebuild` output ("Test session results,
   code coverage, and logs:").

### Measuring Where Time Goes

When a test run completes, the output shows timing breakdown:

```
2026-09-20 17:22:46.984 [MT] IDETestOperationsObserverDebug: 22.065 elapsed -- Testing started completed.
2026-09-20 17:22:46.984 [MT] IDETestOperationsObserverDebug: 0.000 sec, +0.000 sec -- start
2026-09-20 17:22:46.984 [MT] IDETestOperationsObserverDebug: 22.065 sec, +22.065 sec -- end
```

- **Setup phase (1.5-2.5 min):** Simulator boot, app installation, Xcode preparation
- **Test execution (2-3 min):** Running all UI and unit tests

**Key insight:** The setup phase dominates total time - this is why reusing simulators is critical
for iteration speed.

---

## Workflow Overview

Creating a UI test follows a three-step loop:

1. **Create the test spec** - Write the test specification in a `.swift` file
2. **Create the test code** - Implement the test using XCTest and utility functions
3. **Run and iterate** - Run the tests in the simulator and fix until they pass

Before step 3 (or whenever a run starts misbehaving), revisit **Before You Start Debugging
"Simulator" Issues** above.

---

## Step 1: Create the Test Spec Document

Before writing code, create a documentation file that describes what the test should verify. This
helps clarify requirements and provides a reference for implementation.

### File Naming Convention

Create a Markdown document in `doc-ui-tests/` with the naming pattern:
```
ui-tests-<feature-name>.md
```

### Template

```markdown
# Test Name

## What This Test Verifies

Describe what UI behavior this test should verify. Include:
- What user actions are performed
- What UI elements should appear
- What values/labels should be displayed
- Any expected error states

## Test Cases

### Case 1: [Brief description]
1. [Action 1]
2. [Action 2]
3. [Expected result]

### Case 2: [Brief description]
1. [Action 1]
2. [Action 2]
3. [Expected result]

## Accessibility Requirements

List the `accessibilityIdentifier` or `accessibilityLabel` values needed in the app code. Also
note whether the app code needs `.accessibilityValue` in addition to `.accessibilityLabel` for any
dynamic summary text - see "Missing `.accessibilityValue`" above.
```

### Example: Activity Level Test Spec

See `doc-ui-tests/ui-tests-activity-level.md` for a complete example of a test spec document.

---

## Step 2: Create the Test Code

### File Location

Create the test class file in `SimpleTestUITests/` with the naming pattern:
```
SimpleTestUITests_<FeatureName>.swift
```

### Test Class Template

```swift
//
//  SimpleTestUITests_<FeatureName>.swift
//  SimpleTestUITests
//
//  Created by <Your Name> on <Date>.
//

import XCTest

final class SimpleTestUITests_<FeatureName>: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    /// [Test description]
    @MainActor
    func test<DescriptiveName>() throws {
        let app = XCUIApplication()
        app.launch()

        // Your test code here
    }
}
```

### Key Guidelines

1. **Use `@MainActor`** - All UI test methods must run on the main actor
2. **Declare and launch `app` at the top of every test method** - see "A missing variable
   declaration silently blocks the whole test target" above for what happens if you forget.
3. **Use `utils`** - Leverage helper functions from `SimpleTestUITestUtils`:
   - `findPicker(in:)` - Find a wheel picker
   - `findSegmentedControl(in:)` - Find a segmented control
   - `findPickers(in:)` - Find all pickers
   - `waitForElement(_:)` - Wait for an element to appear
   - `waitForElementToDisappear(_:)` - Wait for an element to disappear
   - `waitForStableValue(of:)` - Wait for an animated value to stabilize
   - `selectValueVerified(inSection:value:summaryLabel:validRange:)` - Select a picker value and
     verify (integer-valued pickers only - see "Picker rows aren't always simple integers" above)
   - `collapseAndVerify(inSection:value:summaryLabel:validRange:)` - Collapse and verify value
     persists (integer-valued pickers only)
   - `verifyWithRetry(...)` - Run steps with retry and recovery logic
   - `findSummaryValue(in:withAccessibilityLabel:)` - Find summary value text

4. **Follow naming conventions**:
   - Test method names: `test<WhatIsBeingTested>` (e.g., `testPickerExists`)
   - Section accessibility identifiers: `section<Name>` (e.g., `sectionHeight`)

5. **For string-valued (enum-backed) pickers**, don't reach for `selectValueVerified` - write a
   local equivalent that adjusts the wheel to the full row string and verifies against the
   summary's shorter string. See `SimpleTestUITests_ActivityLevel.swift` for the pattern.

6. **Never toggle a section.** State your intent with `setSection(open: true/false)`, which reads
   the section's published state and taps the disclosure button only if it needs to - see
   "Never toggle a section" above. Never call `section.tap()`.

7. **Address controls by identifier, never by position or `firstMatch`.** `app.pickers["agePicker"]
   .pickerWheels` and `app.segmentedControls["heightUnitSelector"]` resolve to exactly one element
   each. `firstMatch` is an *ambiguity* tool, not a *timing* tool: it silently picks whichever
   element happens to be first in the tree, which matters because Height and Weight each mount
   four wheels simultaneously. Use `waitForExistence` for timing; `XCUIElementQuery` is lazy and
   re-evaluates the whole chain (including the parent) on every poll, so building a query for an
   element inside a collapsed section is perfectly safe.

---

## Step 3: Run and Iterate

### Quick Start Command

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest
```

### Confirm the build first

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug \
  -destination "platform=iOS Simulator,id=<UDID>" build-for-testing
```

### Run All Tests

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest

# Use -collect-test-diagnostics never to prevent timeout during diagnostics collection
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" \
  -collect-test-diagnostics never test
```

**What's happening now:** Starting the test suite. This will take 3-5 minutes. You will see:
- Build phase progress (compiling, linking)
- Test phase: each test method running with pass/fail status
- Final summary with total passed/failed

**Note:** Tests run in the simulator which takes ~30 seconds to launch. Don't worry if you see no
output for the first 30 seconds.

**Note:** The scheme name is `SimpleTest` (not `SimpleTestUITests`) because the UITests target is
included in the main scheme.

**Note:** The `-collect-test-diagnostics never` option prevents xcodebuild from collecting verbose
diagnostics (like sysdiagnose) after test completion, which can cause a 10-minute timeout waiting
for simulator response.

### Run a Single Test

For debugging, run only your test:

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" -collect-test-diagnostics never -skip-testing:"*" -only-testing:"SimpleTestUITests/SimpleTestUITests_<FeatureName>.test<MethodName>" test
```

**Example:**
```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0" -collect-test-diagnostics never -skip-testing:"*" -only-testing:"SimpleTestUITests/SimpleTestUITests_ActivityLevel.testActivityLevelPickerExists" test
```

**Format:** `-only-testing:"<TestBundle>/<TestClass.testMethodName>"`. The `TestBundle` is
typically `SimpleTestUITests`. You can also target a whole class by omitting `.testMethodName`.

### Common Iteration Scenarios

#### 1. Picker Not Found

If the test can't find a picker element:

```bash
# Add diagnostic output to see the accessibility hierarchy
XCTFail("Picker not found. Accessibility hierarchy: \(app.debugDescription)")
```

The same technique - dumping `element.frame` and `element.debugDescription` on failure - is the
fastest way to diagnose a tap landing in the wrong place (see "Tapping a section to collapse it can
silently hit the picker instead" above) or a summary reading back empty (compare against whether
`.accessibilityValue` is actually set in the app code).

#### 2. Value Not Updating

If the picker value isn't updating as expected, use `waitForStableValue`:

```swift
let value = utils.waitForStableValue(of: summaryElement)
XCTAssertEqual(value, "Expected Value")
```

If the value reads back as an empty string specifically (not just wrong), check the app code for a
missing `.accessibilityValue` before assuming a test timing issue.

#### 3. Collapsing Changes Values

If collapsing the section changes values, use `collapseAndVerify` (integer pickers) or a local
equivalent (string pickers, see above):

```swift
XCTAssertTrue(utils.collapseAndVerify(
    inSection: section,
    value: 150,
    summaryLabel: "Summary label",
    validRange: 0...272
), "Value should persist after collapse")
```

If the value doesn't just drift but reverts hard to the section's *default*, and this happens
deterministically (not intermittently), suspect the tap-landing-on-the-picker issue rather than a
settle-timing race - check the section's expanded frame vs. its header frame.

#### 4. Unit Conversion Issues

For tests involving unit conversions, use `verifyWithRetry`:

```swift
let success = utils.verifyWithRetry(
    inSection: section,
    expected: "5 feet 10 inches",
    summaryLabel: "Height summary",
    steps: {
        // Switch units
        unitSelector.buttons["Feet & Inches"].tap()
        section.tap() // collapse
    },
    recover: { actualValue in
        // Re-expand and adjust the underlying value
        section.tap()
        // ... nudge the value based on actualValue
    }
)
```

---

## Utility Function Reference

### `selectValueVerified`

The most commonly used utility. Selects a value in a wheel picker and verifies it against the
section's summary text. **Integer-valued pickers only** - see "Picker rows aren't always simple
integers" above for string/enum-backed pickers like Activity Level.

```swift
static func selectValueVerified(
    inSection section: XCUIElement,
    value: Int,
    summaryLabel: String,
    validRange: ClosedRange<Int>,
    wheelIndex: Int = 0,
    maxAttempts: Int = 3
) -> Bool
```

**Parameters:**
- `section`: The expanded section element (e.g., `app.otherElements["sectionAge"]`)
- `value`: The target value (e.g., `34` for age)
- `summaryLabel`: The accessibility label of the summary text (e.g., `"Age value"`)
- `validRange`: The picker's full range (e.g., `16...99`)
- `wheelIndex`: Which picker wheel to drive (useful when multiple pickers are visible)
- `maxAttempts`: How many times to retry if the value doesn't match

**Returns:** `true` if the value was successfully selected and verified

### `collapseAndVerify`

Collapses a section and verifies the value persists. **Integer-valued pickers only.**

```swift
static func collapseAndVerify(
    inSection section: XCUIElement,
    value: Int,
    summaryLabel: String,
    validRange: ClosedRange<Int>,
    wheelIndex: Int = 0,
    maxAttempts: Int = 3
) -> Bool
```

### `verifyWithRetry`

Runs steps and retries with recovery logic for actions that don't directly control a picker wheel.

```swift
static func verifyWithRetry(
    inSection section: XCUIElement,
    expected: String,
    summaryLabel: String,
    maxAttempts: Int = 3,
    steps: () -> Void,
    recover: (String?) -> Void
) -> Bool
```

---

## Tips for Reliable Tests

1. **Always wait for elements** - Use `waitForElement` or `firstMatch.waitForExistence(timeout:)`

2. **Use stable values** - For animated text, use `waitForStableValue` to wait for transitions to
   complete

3. **Test the summary, not the picker** - The picker's accessibility value can be unreliable; the
   section summary is the ground truth (provided the app code actually sets
   `.accessibilityValue` on it - verify this in the app source if reads are unexpectedly empty)

4. **Handle collapse behavior** - Collapsing can change values; use `collapseAndVerify` (or a
   local equivalent for string pickers) when you need to confirm the value after collapse. If a
   value reverts hard to the default every time rather than drifting intermittently, check where
   the collapse tap physically lands first.

5. **Read the doc comments** - Every utility function has detailed documentation in
   `SimpleTestUITestUtils.swift`. Read it before using.

6. **Start with a single test** - Run just your new test to debug, then add more test methods

7. **Confirm `build-for-testing` succeeds before debugging test behavior** - a build failure
   anywhere in the test target can masquerade as every kind of runtime flakiness.

---

## Common Pitfalls

| Symptom | Cause | Solution |
|---------|-------|----------|
| `Failed to get matching snapshot: Application ... is not running` | The test never called `app.launch()`. `XCUIApplication()` alone only creates a proxy | Add `app.launch()` to the test method. Check the whole target with the grep in "Check These Two Things" above |
| One test in a class fails but its sibling passes, with the same code | The failing one runs first; the passing one inherits a running app from the previous test's `resetAppState()` teardown | Same fix - every test launches its own app. Do not rely on ordering |
| `No segmented control '<id>'. Is the section expanded?` | The section is collapsed, so the editor is not in the tree at all (`if isExpanded { editorView() }`) | Assert `setSection(..., open: true, ...)` immediately before the lookup. It is idempotent |
| The *same* test fails with a different message run to run | A helper's side effect (e.g. `verifyWithRetry`'s `steps` collapsing the section) leaves different state depending on whether a retry path ran | Never inherit state between blocks; state the precondition explicitly |
| `xcodebuild` fails instantly with "multiple devices matched" | Two simulators share the same name/OS | Delete the duplicate, or target by `-destination id=<UDID>` |
| Every test in a target fails/hangs identically | The test target doesn't actually compile | Run `build-for-testing` first and read the compiler error |
| `cannot find 'X' in scope` for a Foundation type | `MemberImportVisibility` upcoming feature; `import XCTest` no longer implies Foundation | Add `import Foundation` explicitly |
| `cannot find 'Process' in scope` | `Process`/`NSTask` doesn't exist on iOS at all | Don't shell out from inside a UI test; do host-side simulator control from the driving script instead |
| Picker not found | Section not expanded | Tap section before finding picker |
| Value off by one | `adjust(toPickerWheelValue:)` artifact | Use `selectValueVerified` with retry logic |
| `Requested adjust to value 'N' which is not one of the possible values ...` | Picker rows are strings, not integers, but an integer was passed | Write a string-aware select/collapse helper (see Activity Level) |
| Validation message never clears | Timing issue | Use `waitForElementToDisappear` instead of `exists` |
| Summary value reads back as `''` even though it's visibly correct | Missing `.accessibilityValue` on the summary view in app code | Add `.accessibilityValue(...)` alongside `.accessibilityLabel(...)` |
| Summary shows wrong value after collapse | Collapse-triggered value corruption | Use `collapseAndVerify` |
| Summary reverts hard to the section's *default* value after every collapse attempt, deterministically | `section.tap()`'s implied tap point lands inside a tall expanded editor instead of the header | Never tap the section container. Use `setSection(open:)`, which taps the disclosure button and verifies the state actually changed |
| A section ends up in the opposite state to the one the test wanted | Code blindly toggled instead of setting a state; the section was not in the assumed state | Read `app.buttons["<sectionId>.disclosure"].value` first and tap only if it differs from the target |
| `section.images["chevron.down"]` finds nothing | The chevron has `.accessibilityAddTraits(.isButton)`, so it is a `button`, not an `image` | `app.buttons["<sectionId>.disclosure"]` |
| A control's identifier resolves to an unexpected string (e.g. `editorHeight` instead of `heightUnitSelector`) | `.accessibilityIdentifier` on a plain ancestor container propagates down and overwrites descendants' identifiers | Do not put identifiers on wrapper containers. An intervening `.accessibilityElement(children: .contain)` blocks the propagation |
| An identifier set on a wheel `Picker` cannot be found at all | `.accessibilityElement(children: .contain)` was added to the `Picker` itself, which removes the identifier from the tree entirely | Put the identifier directly on the `Picker`, with no `.contain`, and query `app.pickers[id].pickerWheels` |
| A test's `print()` output is nowhere to be found | `print()` from a UI test is captured neither by `xcodebuild`'s console nor by `xcresulttool ... activities` | Put diagnostics in an `XCTFail` message or an `XCTAttachment` |
| Value doesn't update after unit switch | Indirect action, needs recovery | Use `verifyWithRetry` with custom recovery |

---

## Checklist Before Submitting

- [ ] Test spec document created (`doc-ui-tests/ui-tests-*.md`)
- [ ] Test class created (`SimpleTestUITests_*.swift`)
- [ ] `xcodebuild ... build-for-testing` succeeds with no errors
- [ ] Test runs successfully in isolation
- [ ] Test passes in full test suite
- [ ] Code follows project style (see existing test files)
- [ ] Accessibility identifiers **and values** are set in app code (not just labels)
- [ ] Documentation updated if behavior changed

---

## Xcode Version Handling

The path to Xcode changes as different versions are installed. The documentation uses
`Xcode-27.2.0-Beta.app` as an example - you will need to update this path when you install a
different Xcode version.

### Check Current Xcode Installation

1. List available Xcode installations:
   ```bash
   ls /Applications/ | grep Xcode
   ```

2. Check which Xcode is currently selected:
   ```bash
   xcode-select -p
   ```

   If this shows `/Library/Developer/CommandLineTools` instead of an Xcode path, you need to switch:
   ```bash
   sudo xcode-select -s /Applications/Xcode-27.2.0-Beta.app/Contents/Developer
   ```

3. Verify the correct Xcode is being used:
   ```bash
   xcodebuild -version
   ```

4. Verify `simctl` is available:
   ```bash
   xcrun -f simctl
   ```

### When Xcode Updates

When you install a new Xcode version, update your environment:

1. Find the new Xcode name:
   ```bash
   ls /Applications/ | grep Xcode
   # Example output: Xcode-27.2.0-Beta.app, Xcode-28.0.app
   ```

2. Update the DEVELOPER_DIR environment variable:
   ```bash
   export DEVELOPER_DIR=/Applications/Xcode-28.0.app/Contents/Developer
   ```

3. Verify the path exists:
   ```bash
   test -d "$DEVELOPER_DIR" && echo "Path exists" || echo "Path not found"
   ```

4. Update xcode-select (permanent):
   ```bash
   sudo xcode-select -s /Applications/Xcode-28.0.app/Contents/Developer
   ```

---

## Performance Notes

**Historic note, now fixed:** the tests used to scan the element tree because
`accessibilityIdentifier` "doesn't reliably propagate from SwiftUI Picker views with
`.pickerStyle(.wheel)`". That was half right - the identifier does not reach the `.pickerWheel`
element (a wheel's own identifier is always `''`), but it *does* land on the enclosing `.picker`
element (verified against the live accessibility tree, §1.3 of
`section-metadata-implementation-spec.md`). Scanning was never necessary. Every wheel in the app is
now reachable by name via `SimpleTestUITestUtils.wheel(_:in:)` / `.segmentedControl(_:in:)`:

```swift
app.pickers["agePicker"].pickerWheels        // exactly one wheel, verified for all ten wheels
app.segmentedControls["heightUnitSelector"]  // segmented controls are addressed directly
```

**Current timing (approximate):**
- Test startup: ~5 seconds (after simulator is ready)
- Per-section scanning: ~10-25 seconds (scanning 70-100 elements at ~0.3s each)
- Total test suite: ~2-4 minutes (test execution only)

**Bottleneck:** Each `element(boundBy:)` call takes ~0.3s due to the remote debugger protocol
between Xcode and the simulator.

**Tips to speed up:**
- Reuse simulators - don't shut them down between test runs
- Run individual tests with `-only-testing:` when debugging
- Consider running tests in parallel (Xcode does this automatically with multiple clones - this
  was confirmed working correctly in this project: parallel clones and per-test app reset via
  `SimpleTestUITestUtils.resetAppState()` are not the source of failures once the target actually
  builds)

---

## Troubleshooting

### "simctl not found" error

This error occurs when `xcode-select` points to the command line tools instead of Xcode. Xcode
includes `simctl` (the simulator control utility), but the standalone Command Line Tools do not.

**Check your setup:**
```bash
# Should show an Xcode path, not CommandLineTools
xcode-select -p

# Should find simctl
xcrun -f simctl
```

**Fix by switching Xcode:**
```bash
sudo xcode-select -s /Applications/Xcode-27.2.0-Beta.app/Contents/Developer
```

**Or set DEVELOPER_DIR in your shell profile** (recommended for persistent setup):

Add to `~/.zshrc` or `~/.bashrc`:
```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
```

Then reload: `source ~/.zshrc` (or `source ~/.bashrc`)

### Simulator doesn't start or hangs

If the simulator takes too long to start or appears to hang:

1. Kill any existing simulators:
   ```bash
   xcrun simctl shutdown all
   ```

2. Check for duplicate simulator names (see "Before You Start Debugging" above) - an ambiguous
   destination can present as a hang depending on the caller.

3. Boot a specific simulator:
   ```bash
   # Get the device UDID for iPhone 17 Pro Max
   xcrun simctl list devices | grep "iPhone 17 Pro Max"

   # Boot it (replace UDID with actual value)
   xcrun simctl boot <UDID>
   ```

### Test runner hangs after all tests complete

If xcodebuild appears to hang after all tests finish (showing "Testing started completed" but not
returning), this is likely due to verbose diagnostics collection timing out while waiting for
simulator response.

**Solution:** Add `-collect-test-diagnostics never` to your xcodebuild command:
```bash
xcodebuild ... -collect-test-diagnostics never test
```

This disables the verbose diagnostics collection (sysdiagnose) that can cause a 10-minute timeout.

### Tests find no elements

1. Check that sections are tapped before looking for elements
2. Wait for expansion animation (~0.3s)
3. The element scan will find elements but may be slow

### Slow tests

The scan is slow because each element lookup is a remote call. Consider:
- Reducing the number of elements to scan (use `children(matching:)` instead of
  `descendants(matching:)` when possible)
- Using `firstMatch` instead of `element(boundBy:)` where available
- Running tests in parallel (Xcode handles this automatically)

### A background/detached `xcodebuild` run appears to finish instantly but the test log is truncated

Check whether the invoking process was double-backgrounded (e.g. `command &` inside a shell that
was *itself* launched in the background). The outer wrapper can report completion as soon as the
inner `&` returns control, while the real `xcodebuild` process is still running or gets killed when
its parent shell exits. Verify with `ps -p <PID>` that the process is actually gone before trusting
a "completed" signal, and prefer launching with a single layer of backgrounding
(`nohup ... & disown`, or a single background-capable tool call) plus an explicit wait loop.

### Known Issue Tests

**Current baseline: 31 passed / 1 failed out of 32** (full suite, 2026-09-22). See §12 of
`section-metadata-implementation-spec.md` for the full run record and the three defects fixed to
get there.

All three defects fixed on 2026-09-22 were in **test code**. The app was correct throughout -
verified by driving it by hand in the Simulator, where every section expands and behaves properly.

1. **`testBodyFatMethodSelectorExists()` / `testCanSelectManualBodyFatEntry()`** - **FIXED**
   - **Symptom:** `XCTAssertTrue failed - Section should expand`, and on other runs
     `Failed to get matching snapshot: Application DaveBerryUk.SimpleTest is not running`.
   - **Root cause:** neither test ever called `app.launch()`. Every other test file launches the
     app per test method; this file had 0 launches across 2 tests. `testCanSelectManualBodyFatEntry`
     passed only because it runs second and inherited the app that the first test's
     `resetAppState()` teardown had launched.
   - **Fix:** added `app.launch()` to both methods.
   - **Time sink warning:** this was misdiagnosed for hours as an app crash. There was never a
     crash - no crash report was ever written, and the SIGTERM seen in `log stream` was routine
     teardown. See "Check These Two Things Before Any Deep Investigation" at the top of this guide.

2. **`testHeightSummaryUpdatesWithUnitOfMeasureChange()` /
   `testWeightSummaryUpdatesWithUnitOfMeasureChange()`** - **FIXED**
   - **Symptom:** `No segmented control 'heightUnitSelector'. Is the section expanded?` - but on
     other runs the same test failed earlier, at
     `Height summary should display '178' after selection`. The varying message was the clue.
   - **Root cause:** *not* floating-point convergence, which is what this document previously
     claimed for the Weight case. `verifyWithRetry`'s `steps` closure ends by collapsing the
     section. When it succeeded without needing a recovery pass it left the section **collapsed**,
     and the Feet &amp; Inches / Stones &amp; Pounds loop immediately after then looked up the unit
     selector - which does not exist in the tree while collapsed. When a recovery pass *was* needed,
     `recover` re-expanded the section and the same code worked, hence the two different messages.
   - **Fix:** assert `setSection(..., open: true, ...)` at the top of the loop before the lookup.
     It is idempotent, so it is safe on the recovery path too.
   - **Note:** the Weight test had been documented as a permanent known failure for some time. It
     now passes. Do not assume a long-standing "known issue" has the cause its note claims.

3. **`testHeightValidationClearsAfterSelection()`** - **OPEN, order-dependent**
   ```bash
   xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug -destination "platform=iOS Simulator,id=4CF378DE-00AB-4BB9-BF60-A83B83C6574F" -collect-test-diagnostics never -skip-testing:"*" -only-testing:"SimpleTestUITests/SimpleTestUITests_Height/testHeightValidationClearsAfterSelection" test
   ```
   - **Symptom:** `XCTAssertTrue failed - Height summary should display '150' after selection`.
   - **Confirmed behaviour:** **passes in isolation, fails when the whole `SimpleTestUITests_Height`
     class runs.** Verified both ways. So this is *order/state dependence*, not a random flake, and
     not the `adjust(toPickerWheelValue:)` artifact on its own.
   - **It only began failing once defect 2 was fixed** - previously
     `testHeightSummaryUpdatesWithUnitOfMeasureChange` aborted early, and now it runs to completion
     and leaves the app in a different state for the next test.
   - **Mechanism not yet pinned.** The app stores no preferences (`grep -rn "AppStorage\|UserDefaults" SimpleTest/`
     returns nothing), so a relaunch should reset the unit of measure - which makes the leak
     non-obvious. **Do not guess.** Start by dumping the unit selector's state at the beginning of
     the failing test.

4. **Historic - `testHeightValidationClearsAfterSelection()` timing issue** - **FIXED earlier**
   - **Root cause:** validation state update hadn't propagated before the test checked.
   - **Fix:** `waitForElementToDisappear()`, polling rather than a synchronous `exists` check.

5. **Activity Level test failures (initial value `''`, selections not persisting)** - **FIXED**
   (this session)
   - **Issue:** All three non-trivial Activity Level tests failed - initial summary value read as
     empty, and selections appeared to revert to "Sedentary" after collapsing.
   - **Root cause:** Two separate bugs, both covered in detail above - a missing
     `.accessibilityValue` on `UISectionSummaryValueActivityLevel` (app code), and
     `section.tap()`'s implied tap landing inside the tall expanded picker instead of the header
     when collapsing (test code).
   - **Fix:** Added `.accessibilityValue(model.activityLevel.displayShortName)` to the app's
     summary view; changed the test's collapse/expand helper to tap the chevron icon specifically
     instead of the whole section frame.
