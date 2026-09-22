# Implementation Spec: Section State Metadata & Deterministic Element Lookup

**Status:** Phases 1-5 are **DONE and VERIFIED** (verified 2026-09-22: all five Phase 5 deletion
gates in §8 print nothing, `build-for-testing` succeeds, and the full suite has been run — see §12
for the baseline). This document is now a historical record of the change, not a TODO list.
**Audience:** Anyone investigating why the test utils/tests look the way they do, or debugging one
of the two undocumented failures logged in §12.

Every accessibility fact in this document was **measured** on Xcode 27.2 / iOS 27.0 Simulator
(iPhone 17 Pro Max, UDID `4CF378DE-00AB-4BB9-BF60-A83B83C6574F`) by dumping the live accessibility
tree. Nothing here is predicted. Where something was tried and did **not** work, it is recorded in
§7 so nobody wastes time retrying it.

---

## 0. Rules For The Implementer — Read First

1. **Phase 1 is already applied.** Do not redo it. Start at Phase 3.
2. **Do not improvise.** If reality does not match this document, **stop and report what you
   found**. Do not invent a different fix, do not "work around it", do not add sleeps. Every
   historic bug in this test suite came from working around a symptom instead of reporting it.
3. **Do not add `sleep()` or `Thread.sleep`** anywhere except as a *poll interval* inside a
   wait-for-condition helper.
4. **Do not use `firstMatch` anywhere in the test target.** Checked by a grep gate in Phase 5.
5. **Do not use `element(boundBy:)`** except inside the two helper functions in §5.3. Also gated.
6. **Never toggle a section; always set it to a known state.** Decide first whether the code is
   trying to **open** or **close** the section, then read the section's published state and tap
   only if it differs. Concretely: no function named `toggle*`, no unconditional `.tap()` on a
   disclosure control, and no `// collapse` comment above a call that does not say `open: false`
   in the code. Intent belongs in the code, not in a comment. See §5.2.
7. **Build after every file you change**, using the command in §4.

---

## 1. The Verified Accessibility Contract

This is the ground truth. Everything in Phases 3-5 follows from it.

| What | How to address it | Verified result |
|---|---|---|
| A section container | `app.otherElements["sectionAge"]` | exists; exposes 93+ descendants |
| A section's open/closed state | `app.buttons["sectionAge.disclosure"]` | `.value` is `"expanded"` or `"collapsed"` |
| Any wheel picker | `app.pickers["<id>"].pickerWheels` | **exactly 1** wheel, for every id below |
| Any segmented control | `app.segmentedControls["<id>"]` | exactly 1, for every id below |

### 1.1 The disclosure element is a BUTTON, not an image

`.accessibilityAddTraits(.isButton)` changes the element's XCUIElementType. The chevron is
`XCUIElement.ElementType.button` (raw value 9) and does **not** appear in `app.images`.

Measured, at launch with everything collapsed:

```
Button, identifier: 'sectionAge.disclosure',                label: 'Age section',                 value: collapsed
Button, identifier: 'sectionGender.disclosure',             label: 'Gender section',              value: collapsed
Button, identifier: 'sectionHeight.disclosure',             label: 'Height section',              value: collapsed
Button, identifier: 'sectionWeight.disclosure',             label: 'Weight section',              value: collapsed
Button, identifier: 'sectionActivityLevel.disclosure',      label: 'Activity Level section',      value: collapsed
Button, identifier: 'sectionBodyFatPercentage.disclosure',  label: 'Body Fat Percentage section', value: collapsed
```

### 1.2 Only six sections exist on the main screen

`sectionMacroSplit` and `sectionCalorieAdjustment` resolve to **nothing** — neither a container nor
a disclosure button. They are not on this screen. Do not put them in `allSectionIds`.

### 1.3 Every wheel is uniquely addressable — one rule, no exceptions

`app.pickers["<id>"].pickerWheels` returns exactly one wheel for all ten:

| Section | Wheel identifiers |
|---|---|
| Age | `agePicker` |
| Height | `heightCmWheel`, `heightInchesWheel`, `heightFeetWheel`, `heightFeetInchesWheel` |
| Weight | `weightKgWheel`, `weightPoundsWheel`, `weightStonesWheel`, `weightStonesPoundsWheel` |
| Activity Level | `activityLevelPicker` |
| Body Fat | `bodyFatPicker`, `bodyFatDecimalPicker` |

**This is what removes the `wheelIndex` parameter.** Height and Weight still keep all four wheels
mounted at once (`app.pickerWheels.count == 4` when either section is expanded), but you never
index into that list again — you name the wheel you want.

### 1.4 Segmented controls

`app.segmentedControls["<id>"]` — note these are addressed **directly**, not as a container:

`Gender`, `heightUnitSelector`, `weightUnitSelector`, `bodyFatMethodSegmentedControl`

### 1.5 Body Fat wheels require Manual Entry first

`bodyFatPicker` / `bodyFatDecimalPicker` do not exist until the method segmented control is set to
**Manual Entry**. The segments are exactly `Omit`, `Estimate`, `Manual Entry`. With Manual Entry
selected, both wheels resolve and `sectionBodyFatPercentage` reports 2 wheels.

---

## 2. Why These Changes (the original defects)

### 2.1 `firstMatch` at app scope picks an arbitrary element

`findPicker` does `app.pickerWheels.firstMatch` — "the first picker wheel anywhere in the app".

`firstMatch` is an **ambiguity** tool, not a **timing** tool. Without it, a query matching several
elements raises a loud error. With it, XCUITest silently picks whichever is first in the tree. It
did not fix a timing problem — it converted a loud, correct error into a silent wrong-element
selection that surfaces later as a value that will not converge. With Height and Weight each
mounting four wheels, this is a real and frequent misfire.

### 2.2 Collapsed sections genuinely do not exist

`UILayoutSectionView` is `if isExpanded { editorView() }`. When collapsed, the editor is not in the
tree at all. The tool for that is `waitForExistence`, which the tests already call.

`XCUIElementQuery` is **lazy**: `app.pickers["agePicker"].pickerWheels` describes how to find an
element; nothing resolves until `.exists`, `.waitForExistence`, or an interaction.
`waitForExistence` re-evaluates the whole chain on every poll, **including the parent**. Building a
query for an element inside a collapsed section is therefore completely safe. Scoping and waiting
are orthogonal; you want both.

### 2.3 There was no way to ask "is this section open?"

Tests tapped and hoped. When a collapse tap landed on the picker instead of the header, it silently
adjusted a value and the test carried on into a confusing failure. §1.1 fixes this.

### 2.4 Pre-existing bug found while writing this spec

`SimpleTestUITestUtils.resetAppState` iterates `"sectionBodyFat"`. The app defines
`"sectionBodyFatPercentage"`. That entry has never matched anything. Fixed in §5.5.

---

## 3. Phase 1 — App Changes (DONE, for reference)

All of the following are already applied and verified.

1. **`UILayoutSectionView.swift`** — the chevron now carries the disclosure state:
   ```swift
   .accessibilityIdentifier(accessibilityId.map { "\($0).disclosure" } ?? "")
   .accessibilityLabel("\(title) section")
   .accessibilityValue(isExpanded ? "expanded" : "collapsed")
   .accessibilityAddTraits(.isButton)
   ```
   and the contradictory bare `.accessibilityElement()` was removed, leaving only
   `.accessibilityElement(children: .contain)`.

2. **`UILayoutExpandingPanel.swift`** — bare `.accessibilityElement()` (which means
   `children: .ignore` and hid the whole subtree) replaced with
   `.accessibilityElement(children: .contain)`. This is what makes the Body Fat controls visible.

3. **Every wheel Picker** carries `.accessibilityIdentifier("<id>")` **directly on the `Picker`**,
   with no `.accessibilityElement(children: .contain)` and no `.accessibilityLabel` /
   `.accessibilityValue` on the same Picker.

4. **Every segmented control** carries `.accessibilityIdentifier("<id>")` directly.

5. **All `editorX` identifiers were deleted** from `SimpleTest/ViewSectionEditors/*.swift`. See
   §7.2 — they were actively harmful.

---

## 4. Build Command

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.2.0-Beta.app/Contents/Developer
export PATH=$DEVELOPER_DIR/usr/bin:$PATH
cd /Users/davidberry/sources/ios/SimpleTest
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug \
  -destination "platform=iOS Simulator,id=4CF378DE-00AB-4BB9-BF60-A83B83C6574F" build-for-testing
```

Must print `** TEST BUILD SUCCEEDED **`.

> Target the simulator **by UDID**. There are two devices named `iPhone 17 Pro Max` (iOS 26.5 and
> iOS 27.0). `OS=27.0` also disambiguates, but a bare `name=` destination does not.

> **Reading results:** `xcodebuild`'s console does **not** capture `print()` from a UI test, and
> neither does `xcresulttool get test-results activities`. To surface diagnostics from inside a
> test, put them in an `XCTFail` message or an `XCTAttachment`. Read them with:
> ```bash
> xcrun xcresulttool get test-results summary --path <bundle>.xcresult
> ```

---

## 5. Phase 3 — Rewrite `SimpleTestUITestUtils` (TODO)

### 5.1 Section state constants and lookup

```swift
    // MARK: - Section State

    static let sectionExpanded = "expanded"
    static let sectionCollapsed = "collapsed"

    /// Sections present on the main screen. `sectionMacroSplit` and `sectionCalorieAdjustment`
    /// are deliberately absent - they do not exist in this screen's accessibility tree.
    static let allSectionIds = [
        "sectionAge",
        "sectionGender",
        "sectionHeight",
        "sectionWeight",
        "sectionActivityLevel",
        "sectionBodyFatPercentage",
    ]

    /// A section's disclosure control. It is a BUTTON, not an image: the view sets
    /// `.accessibilityAddTraits(.isButton)`, which determines the XCUIElement type.
    /// Its accessibility value is the section's open/closed state.
    static func disclosure(forSection sectionId: String, in app: XCUIApplication) -> XCUIElement {
        return app.buttons["\(sectionId).disclosure"]
    }

    /// Whether a section is currently expanded. Nil if the disclosure cannot be found.
    static func isSectionExpanded(_ sectionId: String, in app: XCUIApplication, timeout: TimeInterval = 5.0) -> Bool? {
        let d = disclosure(forSection: sectionId, in: app)
        guard d.waitForExistence(timeout: timeout), let v = d.value as? String else { return nil }
        return v == sectionExpanded
    }
```

### 5.2 Idempotent section toggle

```swift
    /// Puts a section into the requested state and waits until the UI confirms it.
    ///
    /// Idempotent: if the section is already in the requested state this does nothing and
    /// succeeds. That matters because a tap that misses the header used to silently adjust a
    /// picker value and let the test continue; now a missed tap leaves the state unchanged and is
    /// retried, so it can no longer corrupt a value.
    ///
    /// Only the disclosure button is ever tapped. Never tap the section container:
    /// `XCUIElement.tap()` hits the geometric centre of the element's frame, and for a tall
    /// expanded editor that centre is inside the picker, not the header.
    @discardableResult
    static func setSection(_ sectionId: String, open: Bool, in app: XCUIApplication, timeout: TimeInterval = 5.0, maxAttempts: Int = 3) -> Bool {
        let d = disclosure(forSection: sectionId, in: app)
        guard d.waitForExistence(timeout: timeout) else { return false }
        let target = open ? sectionExpanded : sectionCollapsed

        for _ in 1...maxAttempts {
            if d.value as? String == target { return true }
            if !d.isHittable { app.swipeUp() }
            d.tap()
            if waitForValue(of: d, toEqual: target, timeout: timeout) { return true }
        }
        return false
    }

    /// Polls an element's accessibility value until it equals `expected`. Use this instead of
    /// sleeping after an action that changes state.
    static func waitForValue(of element: XCUIElement, toEqual expected: String, timeout: TimeInterval = 5.0, pollInterval: TimeInterval = 0.05) -> Bool {
        var elapsed: TimeInterval = 0
        while elapsed < timeout {
            if element.value as? String == expected { return true }
            Thread.sleep(forTimeInterval: pollInterval)
            elapsed += pollInterval
        }
        return false
    }
```

### 5.3 Replace `findPicker` / `findPickers` / `findSegmentedControl`

**Delete all three.** Replace with:

```swift
    // MARK: - Control Lookup
    //
    // Both helpers resolve a control by accessibility identifier, never by position and never by
    // "whichever one is first".
    //
    // An identifier set on a `.wheel` Picker does NOT reach the underlying `.pickerWheel` element
    // (the wheel's own identifier is always ''). It lands on the enclosing `.picker` element, so
    // the wheel is reached as `app.pickers[id].pickerWheels`. Verified for all ten wheels.
    //
    // `element(boundBy: 0)` appears here and nowhere else in the target. It is safe only because
    // the count is asserted to be exactly 1 first, so there is no ambiguity for it to hide.

    /// The single picker wheel belonging to the Picker with the given identifier.
    static func wheel(_ pickerId: String, in app: XCUIApplication, timeout: TimeInterval = 5.0,
                      file: StaticString = #filePath, line: UInt = #line) -> XCUIElement? {
        let wheels = app.pickers[pickerId].pickerWheels
        guard wheels.element(boundBy: 0).waitForExistence(timeout: timeout) else {
            XCTFail("No picker wheel found for '\(pickerId)'. Is the section expanded? For bodyFatPicker, is Manual Entry selected?", file: file, line: line)
            return nil
        }
        guard wheels.count == 1 else {
            XCTFail("Expected exactly 1 wheel for '\(pickerId)', found \(wheels.count).", file: file, line: line)
            return nil
        }
        return wheels.element(boundBy: 0)
    }

    /// The segmented control with the given identifier. Addressed directly, not via a container.
    static func segmentedControl(_ id: String, in app: XCUIApplication, timeout: TimeInterval = 5.0,
                                 file: StaticString = #filePath, line: UInt = #line) -> XCUIElement? {
        let control = app.segmentedControls[id]
        guard control.waitForExistence(timeout: timeout) else {
            XCTFail("No segmented control '\(id)'. Is the section expanded?", file: file, line: line)
            return nil
        }
        return control
    }
```

### 5.4 Fix `findSummaryValue`

Remove the `.firstMatch`:

```swift
    static func findSummaryValue(in sectionElement: XCUIElement, withAccessibilityLabel label: String, timeout: TimeInterval = 2.0) -> XCUIElement? {
        let matches = sectionElement.descendants(matching: .staticText)
            .matching(NSPredicate(format: "label == %@", label))
        guard matches.element(boundBy: 0).waitForExistence(timeout: timeout) else { return nil }
        return matches.element(boundBy: 0)
    }
```

### 5.5 Rewrite `resetAppState`

The current version sleeps 4+ seconds, uses `section.pickerWheels.firstMatch.exists` as a proxy for
"is it expanded", taps the section container to collapse, and looks up a section id that does not
exist. All four problems go away:

```swift
    static func resetAppState() {
        let app = XCUIApplication()
        app.terminate()
        app.launch()
        for sectionId in allSectionIds {
            setSection(sectionId, open: false, in: app)
        }
    }
```

### 5.6 Rewrite `launchFreshApp`

Drop the `sleep(1)`:

```swift
    static func launchFreshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.terminate()
        app.launch()
        return app
    }
```

### 5.7 `selectValueVerified` — replace `wheelIndex` with `wheelId`

```swift
    static func selectValueVerified(inSection section: XCUIElement, value: Int, summaryLabel: String,
                                    validRange: ClosedRange<Int>, wheelId: String, maxAttempts: Int = 3) -> Bool {
        let app = XCUIApplication()
        var requestedValue = value

        for attempt in 1...maxAttempts {
            guard let w = wheel(wheelId, in: app) else { return false }
            w.adjust(toPickerWheelValue: "\(requestedValue)")

            let summary = findSummaryValue(in: section, withAccessibilityLabel: summaryLabel)
            let actual = summary.flatMap { waitForStableValue(of: $0) }.flatMap { Int($0) }
            if actual == value { return true }

            if attempt < maxAttempts, let actual {
                let corrected = value + (value - actual)
                requestedValue = min(max(corrected, validRange.lowerBound), validRange.upperBound)
            }
        }
        return false
    }
```

**Keep the existing doc comment**, but delete the `wheelIndex` paragraph — the positional
workaround no longer exists — and replace it with a `wheelId` description. Everything else in that
comment records real, still-valid findings about `adjust(toPickerWheelValue:)`.

### 5.8 `collapseAndVerify` — take a `sectionId`, stop tapping the container

```swift
    static func collapseAndVerify(inSection section: XCUIElement, sectionId: String, value: Int,
                                  summaryLabel: String, validRange: ClosedRange<Int>,
                                  wheelId: String, maxAttempts: Int = 3) -> Bool {
        let app = XCUIApplication()

        for attempt in 1...maxAttempts {
            guard setSection(sectionId, open: false, in: app) else { return false }

            let summary = findSummaryValue(in: section, withAccessibilityLabel: summaryLabel)
            let actual = summary.flatMap { waitForStableValue(of: $0) }.flatMap { Int($0) }
            if actual == value { return true }

            guard attempt < maxAttempts, let actual else { return false }

            guard setSection(sectionId, open: true, in: app) else { return false }
            let corrected = value + (value - actual)
            let clamped = min(max(corrected, validRange.lowerBound), validRange.upperBound)
            guard selectValueVerified(inSection: section, value: clamped, summaryLabel: summaryLabel,
                                      validRange: validRange, wheelId: wheelId) else { return false }
        }
        return false
    }
```

---

## 6. Phase 4 — Migrate The Test Files (TODO)

### 6.1 Mechanical substitutions

| Current | Replacement |
|---|---|
| `section.tap()` to expand | `XCTAssertTrue(utils.setSection("sectionX", open: true, in: app))` |
| `section.tap()` to collapse | `XCTAssertTrue(utils.setSection("sectionX", open: false, in: app))` |
| `if section.pickerWheels.firstMatch.exists { section.tap() }` | `utils.setSection("sectionX", open: false, in: app)` |
| `utils.findPicker(in: app)` | `utils.wheel("<wheelId>", in: app)` |
| `app.pickerWheels.firstMatch` | `utils.wheel("<wheelId>", in: app)` |
| `app.descendants(matching: .segmentedControl).firstMatch` | `utils.segmentedControl("<id>", in: app)` |
| `section.descendants(matching: .segmentedControl).firstMatch` | `utils.segmentedControl("<id>", in: app)` |
| `utils.findPickers(in: app)` | separate `utils.wheel(...)` calls, one per identifier |
| `wheelIndex: 0` | `wheelId: "<id>"` |
| `app.staticTexts["TDEE"].firstMatch` | `app.staticTexts["TDEE"]` |
| `section.images["chevron.down"]` | `utils.disclosure(forSection: "sectionX", in: app)` — **it is a button now** |

### 6.2 Section ↔ control map

| Section | Section id | Wheels | Segmented control |
|---|---|---|---|
| Age | `sectionAge` | `agePicker` | — |
| Gender | `sectionGender` | — | `Gender` |
| Height | `sectionHeight` | `heightCmWheel`, `heightInchesWheel`, `heightFeetWheel`, `heightFeetInchesWheel` | `heightUnitSelector` |
| Weight | `sectionWeight` | `weightKgWheel`, `weightPoundsWheel`, `weightStonesWheel`, `weightStonesPoundsWheel` | `weightUnitSelector` |
| Activity Level | `sectionActivityLevel` | `activityLevelPicker` | — |
| Body Fat | `sectionBodyFatPercentage` | `bodyFatPicker`, `bodyFatDecimalPicker` *(Manual Entry only)* | `bodyFatMethodSegmentedControl` |

### 6.3 Sites that must change

One file at a time, building after each.

- **`SimpleTestUITests_Age.swift`** — lines 26, 108
- **`SimpleTestUITests_Gender.swift`** — line 25
- **`SimpleTestUITests_Height.swift`** — lines 26, 116, 121, 143, 160
- **`SimpleTestUITests_Weight.swift`** — lines 30, 121, 126, 148, 165
- **`SimpleTestUITests_BodyFat.swift`** — line 29
- **`SimpleTestUITests_ActivityLevel.swift`** — lines 37, 53, 99, plus the local
  `selectActivityLevel` / `collapseAndVerifyActivityLevel` helpers.
  **Line 37 is currently broken at runtime**: `section.images["chevron.down"]` no longer resolves,
  because the chevron is now a button carrying `sectionActivityLevel.disclosure`. This is the only
  existing test that the Phase 1 app changes break. Fix it first:
  ```swift
  let chevron = utils.disclosure(forSection: "sectionActivityLevel", in: app)
  ```
- **`SimpleTestUITests_Launch.swift`** — lines 29, 45, 46

### 6.4 Intent, not toggling

When you convert a call site, read the surrounding comment to recover what the code was *trying*
to do, and encode that in the call:

| Before | After |
|---|---|
| `toggleSection(section) // collapse` | `XCTAssertTrue(utils.setSection("sectionX", open: false, in: app))` |
| `toggleSection(section) // re-expand` | `XCTAssertTrue(utils.setSection("sectionX", open: true, in: app))` |
| `if section.pickerWheels.firstMatch.exists { section.tap() }` | `utils.setSection("sectionX", open: false, in: app)` |

The third row is the important one: the `if` was a *guess* at the current state, inferred from
whether a picker happened to be visible. `setSection` reads the state directly and is idempotent,
so the guard disappears entirely - along with the `sleep(1)` that usually followed it.

**`SimpleTestUITests_ActivityLevel.swift` has already been migrated this way** and is a worked
example: its local `setSection(open:)` helper and all nine call sites. Copy that shape.

### 6.5 Assert the return value

`setSection` returns `Bool`. **Assert it**, never discard it — a silently-ignored `false` recreates
exactly the class of bug this change removes.

---

## 7. Things That Were Tried And Do NOT Work

Recorded so nobody burns a day rediscovering them.

### 7.1 `.accessibilityElement(children: .contain)` on a Picker

Putting `.contain` **on the `Picker` itself** makes the identifier vanish from the tree entirely —
not just from the wheel, but from every element type (`anyWithId=0`). Putting it on an enclosing
`ZStack` *does* work (the id then resolves as an `otherElement` containing one wheel), but it is a
second, redundant pattern. The app standardises on the identifier directly on the `Picker`, reached
via `app.pickers[id]`. **Do not add `.contain` to a Picker.**

### 7.2 `.accessibilityIdentifier` on a plain container propagates DOWN and overwrites

`SectionEditorHeight` had `.accessibilityIdentifier("editorHeight")` on a plain `VStack`. That
identifier propagated onto the segmented control inside it, so
`app.segmentedControls["heightUnitSelector"]` found nothing while
`app.segmentedControls["editorHeight"]` found the control. The `editorX` identifiers were never
addressable in their own right (`app.otherElements["editorHeight"].exists == false`) — they only
clobbered inner identifiers. **All `editorX` identifiers have been deleted. Do not reintroduce
them.** An intervening `.accessibilityElement(children: .contain)` blocks the propagation, which is
why Body Fat's control survived while Height's did not.

### 7.3 `.accessibilityHidden(!show)` on inactive unit variants does nothing

Height and Weight mount every unit variant at once and switch `.opacity` / `.allowsHitTesting`.
Adding `.accessibilityHidden(!show)` to the inactive ones had **no effect** — all four wheels
remained in the tree (`app.pickerWheels.count == 4`) and all reported `isHittable == true`. The
modifiers were removed again rather than left as dead code that looks like it does something.

This does not matter for tests, because §1.3 addresses each wheel by name. It does mean a VoiceOver
user can still reach invisible pickers — a genuine accessibility bug, out of scope here, worth
raising separately.

### 7.4 `print()` from a UI test is not captured anywhere useful

Not in `xcodebuild`'s console output, and not in
`xcresulttool get test-results activities`. Use `XCTFail` messages or `XCTAttachment`.

---

## 8. Phase 5 — Deletion Gates

All must print nothing, run from the repo root.

```bash
grep -rn "firstMatch" SimpleTestUITests/
```

```bash
grep -rn "boundBy" SimpleTestUITests/ | grep -v "SimpleTestUITestUtils.swift"
```

```bash
grep -rn "sleep(" SimpleTestUITests/ | grep -v "waitForStableValue\|waitForValue\|pollInterval"
```

```bash
grep -rn "wheelIndex" SimpleTestUITests/
```

```bash
grep -rn "accessibilityElement()" SimpleTest/
```

---

## 9. Acceptance Checklist

- [x] `findPicker`, `findPickers`, `findSegmentedControl` deleted
- [x] `wheel(_:in:)`, `segmentedControl(_:in:)`, `setSection(_:open:in:)`, `waitForValue(of:toEqual:)`,
      `isSectionExpanded(_:in:)`, `disclosure(forSection:in:)`, `allSectionIds` added
- [x] `resetAppState` uses `allSectionIds` and contains no `sleep`
- [x] No test taps a section container; only disclosure buttons are tapped
- [x] Every `setSection` call is wrapped in `XCTAssertTrue`
- [x] All five Phase 5 grep gates print nothing (re-verified 2026-09-22)
- [x] `build-for-testing` succeeds (re-verified 2026-09-22)
- [x] Full suite run; results read from the `.xcresult` summary, not the console log — see §12
- [x] Pass/fail counts recorded as the new baseline — see §12 (no prior-change baseline exists to
      diff against; this run **is** the baseline going forward)
- [x] `ui-testing-guide.md` updated — see §10

---

## 12. Verified Test Baseline (2026-09-22)

Full suite run via:

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug \
  -destination "platform=iOS Simulator,id=4CF378DE-00AB-4BB9-BF60-A83B83C6574F" \
  -collect-test-diagnostics never test
```

**Result: 29 passed / 3 failed (32 total).**

| Test | Status | Notes |
|---|---|---|
| `SimpleTestUITests_Weight.testWeightSummaryUpdatesWithUnitOfMeasureChange()` | **Failed (expected)** | Pre-existing, documented in `ui-testing-guide.md` §"Known Issue Tests" — floating-point rounding across repeated unit conversions. Unrelated to this spec's changes (see §11). |
| `SimpleTestUITests_Height.testHeightSummaryUpdatesWithUnitOfMeasureChange()` | **Failed (undocumented)** | `XCTAssertTrue failed - Height summary should display '178' after selection`. Not listed anywhere as a known issue. Needs investigation — likely the same class of unit-conversion rounding as the Weight failure, but not confirmed. |
| `SimpleTestUITests_BodyFat.testBodyFatMethodSelectorExists()` | **Failed (undocumented)** | `XCTAssertTrue failed - Section should expand`. Not a rounding issue — `setSection(open: true)` itself failed to confirm expansion for `sectionBodyFatPercentage`. Needs investigation; could be a flake (parallel clone contention) or a real regression in the Body Fat section's disclosure behavior. Re-run in isolation with `-only-testing:` before assuming either. |

All other 29 tests, across Age, Gender, Height, Weight, Activity Level, Body Fat, and Launch, passed
including `testHeightValidationClearsAfterSelection()` (previously fixed, confirmed still passing).

**This is now the baseline for future runs.** The two undocumented failures are not yet triaged —
do not assume they are flakes or that they are real regressions without re-running in isolation.

---

## 10. Documentation That Is Now Obsolete

`doc-ui-tests/instructions/ui-testing-guide.md` needs these corrections:

- **Performance Notes** claims tests use element scanning because identifiers "don't reliably
  propagate from SwiftUI Picker views". Half right: they don't reach the `.pickerWheel`, but they
  do reach the enclosing `.picker`, so scanning was never necessary. Replace with §1.3.
- **Common Pitfalls** rows about `section.tap()` landing on the picker are obsolete — tapping the
  section container is now banned outright.
- The **"Tapping a section to collapse it"** section recommends `section.images["chevron.down"]`.
  The chevron is now a **button** with a stable identifier; update to
  `app.buttons["<sectionId>.disclosure"]`.
- Add a note that `print()` from a UI test is invisible (§7.4).
- Add the duplicate-simulator finding: the two `iPhone 17 Pro Max` devices differ by runtime
  (iOS 26.5 and iOS 27.0), so `OS=27.0` disambiguates — but prefer the UDID.

---

## 11. What This Does Not Fix

- **The `adjust(toPickerWheelValue:)` off-by-one is untouched.** It is a synthetic-gesture artifact
  documented in `SimpleTestUITestUtils.swift`. The nudge-and-retry logic stays.
- **`testWeightSummaryUpdatesWithUnitOfMeasureChange` is expected to still fail** — floating-point
  rounding across repeated unit conversions, unrelated to element lookup.
- **`isExpanded` flips at the *start* of the spring animation**, so `setSection` returning true
  means the state changed, not that the animation finished. `utils.wheel(...)` still waits for the
  wheel's existence, and `waitForStableValue` is still required before trusting a summary read.
- **Inactive unit variants remain reachable by VoiceOver** (§7.3).
