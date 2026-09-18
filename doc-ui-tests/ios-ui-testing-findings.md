# Findings: Writing Reliable XCUITest UI Tests for SwiftUI Wheel Pickers

## Overview

This document captures what was learned building and hardening the UI tests for the Age,
Gender, and Height sections. Most of the hard-won lessons here are about **SwiftUI
`.pickerStyle(.wheel)` pickers interacting badly with XCUITest's synthetic gestures and
accessibility tree** - none of this is specific to this app's business logic, and it should
generalize to any SwiftUI project using wheel pickers.

Several of these were diagnosed empirically, by adding temporary debug logging (writing to a
file the host process could read, since UI test code runs on the Mac host, not inside the
simulator) and instrumented runs, then removing the scaffolding once the root cause was
confirmed. That approach is recommended over guessing when a picker test misbehaves in a way
that doesn't match the obvious explanation - several of the bugs below looked at first like
ordinary flakiness and turned out to be something more specific and reproducible.

---

## 1. `Thread.sleep` is almost never the right fix

The original test utilities used fixed `Thread.sleep(forTimeInterval:)` calls (often 1.0s)
before every element lookup. This is a classic anti-pattern:

- It either wastes time (the UI was ready in 100ms but the test waits a full second anyway) or
  isn't long enough (a slower CI runner needs more), and it can't do both.
- It masks real timing bugs rather than exposing them - see the animation and settle issues
  below, several of which were only found *because* the blind sleeps were removed.

**Fix**: use condition-based waits - `element.waitForExistence(timeout:)`, or a predicate/poll
loop when waiting for a *value* to change rather than an element to appear. This was the
starting point for the whole investigation and remains the right default.

## 2. `accessibilityIdentifier`/`accessibilityValue` set on a SwiftUI `Picker` don't propagate to
   the underlying `.pickerWheel` XCUIElement

For `.pickerStyle(.wheel)`, modifiers like `.accessibilityIdentifier("agePicker")` or
`.accessibilityValue(...)` applied to the `Picker` wrapper attach to a different accessibility
node than the actual `.pickerWheel` element XCUITest interacts with. Confirmed by:

- Setting a unique identifier on each of Height's four wheel variants (cm/inches/feet/feet-
  inches) and then querying `app.pickerWheels["heightCmWheel"]` - it did not match; XCTest
  reported "No matches found ... from input {PickerWheel, PickerWheel, PickerWheel, PickerWheel}"
  with none of them carrying the identifier.

**Consequence**: don't rely on identifiers to distinguish or target `.wheel` pickers. Fall back
to **position** (`app.pickerWheels.element(boundBy: n)`), which is stable because SwiftUI
preserves source-declaration order in the accessibility tree regardless of which variant is
currently visible (see #5). Still set the identifiers/values in production code anyway - they
may be inert for XCUITest, but they're real accessibility metadata for VoiceOver users, which is
a separate and equally valid reason to have them.

## 3. `XCUIElement.adjust(toPickerWheelValue:)` can silently commit the wrong row

The wheel's own self-reported `.value` after `adjust(toPickerWheelValue:)` can say the requested
row was reached, while the underlying SwiftUI `@Binding` actually committed an **adjacent**
value. This is a synthetic-gesture artifact - it does not reproduce with real touch input - and
it does not resolve itself by waiting longer; it's a wrong final value, not a slow one.

**Fix**: never trust the wheel's own value. Read ground truth from somewhere else that's
actually wired to the model - in this app, the section's summary text (see #7 for why that
still needs a settle wait). If a plain re-request with the same target doesn't converge, nudge
the *requested* value by the observed error (`requestedValue = target + (target - actual)`) and
retry, since the commit error is deterministic for a given request rather than a timing race -
repeating the identical request reproduces the identical wrong result.

## 4. The picker's very last row is a harder case, not just a bigger version of #3

At the maximum value of a wheel's range, `adjust` can leave the wheel permanently believing it's
already at the target - repeating the same request is a no-op forever, because from the wheel's
own (wrong) point of view, nothing needs to change. There's also no valid in-range value to
*over*-request as a correction, since the target is already the ceiling.

**Fix**: don't try to force a full round-trip commit at the exact boundary through this
mechanism. If the test's actual intent is "the maximum value is a real, selectable option" (as
opposed to "selecting it correctly updates downstream state"), it's enough to confirm `adjust`
doesn't reject the value as out-of-range - `adjust(toPickerWheelValue:)` throws a hard test
failure for genuinely invalid values, so accepting it is itself a meaningful assertion. Verifying
the *exact* committed value at the boundary may not be achievable through synthetic gestures at
all in a given SDK/simulator combination.

## 5. Multiple wheel variants can be mounted simultaneously, even when only one is visible

Where a control switches between unit representations (here: Height's cm / inches / feet+inches
wheels, built as a `ZStack` with `.opacity`/`.allowsHitTesting` toggling based on the active
unit), **all variants exist in the accessibility tree at once** - `app.pickerWheels.count` was 4
even when only one was visually active. `isHittable` was not a reliable signal for which one was
actually live (all but one reported `hittable=true` in one diagnostic run, the *opposite* of
what the visible unit would suggest).

**What did work**: fixed positional indexing matching the view's source declaration order (index
0 = the first-declared wheel variant), combined with the app's own `guard unitOfMeasure == .X`
checks in each `onChange` handler as a safety net - adjusting a non-active wheel is a guaranteed
no-op on the model, so a wrong index fails safely (the verification loop just won't converge)
rather than silently corrupting state.

## 6. Reading a summary/value that's "always rendered" doesn't require collapsing first

An earlier design collapsed a section specifically to force a read of "the real committed state"
from its summary text, on the theory that the wheel couldn't be trusted while expanded and the
summary was somehow more truthful once collapsed. That's true for the wheel, but the section
summary text (e.g. "34 years") is part of the section's **always-visible header row** - it's
bound to the same model property regardless of whether the section is expanded, so it can be
read directly without collapsing at all.

Removing the collapse/re-expand from the verification loop was not just faster (it cut real
wall-clock time by removing two animated section-toggle round trips per attempt) - it also
avoided a bug that collapsing itself introduced (#8). If a value is readable without tearing down
a view, prefer that.

## 7. Value-changing animations need a settle wait even when reading a "trustworthy" element

Even the summary text (a real source of truth per #6) uses `.contentTransition(.numericText())`
+ `.animation(.easeInOut, value:)`, and its accessibility `.value` can be read mid-transition -
not stale exactly, but not the final committed value either. A screenshot taken during a failing
run visually showed overlapping/blurred digits mid-animation, confirming this wasn't a logic bug.

Two traps to avoid when writing the fix:

- **A single "did the last two reads match" check isn't enough.** A value can sit on a
  pre-change (or, worse, a coincidentally target-matching intermediate) reading across two or
  three quick polls before the real transition catches up and changes it again. Require more
  consecutive matches, or a longer minimum wait, than feels necessary at first.
- **The settle time isn't fixed** - it scales with how large a jump the picker made (physical
  wheel deceleration after a big `adjust()` jump can outlast the value-change animation's own
  duration). A wait tuned against a small selection can still be too short for a large one.

**Fix used here**: wait out a documented minimum (SwiftUI's default `.easeInOut` duration, so
not an arbitrary guess) before beginning to poll, then require three consecutive matching reads,
not one or two, before trusting the value.

## 8. Collapsing (or otherwise recreating) a wheel view can permanently corrupt an
   already-verified value - and this is not a timing issue

This was the most surprising finding. A value confirmed correct while a section was expanded
could read back **wrong** immediately after collapsing the section - and, critically, this was
confirmed via a 4-second poll (every 0.2s) to be **permanently** wrong, not a transient
mid-animation reading. Collapsing a section (in this app's pattern: `if isExpanded { editorView()
}`) tears down and rebuilds the whole editor subtree, including the wheel's `@State`. The fresh
view's initial layout can apparently land on a different row than the one it was initialized
with, silently overwriting the model with a slightly wrong value on remount.

This happened both on plain collapse (Age, off by exactly one) and when switching between unit
variants that force a remount (Height, off by one or two, and can compound across a second unit
switch).

**Fix**: treat this the same way as the `adjust` off-by-one (#3) - a deterministic error that
needs a nudge-and-retry correction, not a longer wait. Since the *action* that introduces the
error differs by context (a section collapse vs. a unit-selector switch, which has no direct
wheel to re-adjust), the correction mechanism has to differ too:

- Where the same control can be re-driven (e.g. re-selecting a wheel value after a bad collapse),
  nudge the request by the observed error and retry, exactly as in #3.
- Where the corrupted value is only reachable *indirectly* - e.g. Height's unit-of-measure
  switch reads an already-committed centimeters value through a conversion, with no inches wheel
  to nudge - convert the observed error back through the same ratio the app itself uses (inches
  error × 2.54 ≈ cm nudge) and re-select the underlying value that way instead.
- Check **every** value the assertion depends on, not just the first one that happens to match.
  A feet-and-inches retry that only checked the "5" (feet) digit converged successfully while
  silently leaving the minor "inches" digit wrong (5 feet 8 inches instead of 5 feet 10) - the
  retry condition has to cover the whole displayed value, not a subset that happens to look
  right.

---

## General recommendations for future SwiftUI wheel-picker tests

1. **Never trust the wheel's own value for correctness.** Read from something bound to the real
   model - a summary label, not the picker.
2. **Don't rely on `accessibilityIdentifier` to disambiguate `.wheel` pickers.** It doesn't
   propagate reliably; use stable positional indexing instead, and lean on any `guard`/no-op
   safety nets already in the view code so a wrong guess fails safely rather than corrupting
   state silently.
3. **Any retry-with-correction loop needs to be prepared for a stuck fixed point**, not just
   ordinary flakiness - repeating an identical request can reproduce an identical wrong result
   forever (seen at both the picker's last row, and after a collapse/remount).
4. **Prefer reading state without tearing down a view**, if the state is actually accessible that
   way. Collapsing/expanding to "force a fresh read" can introduce more bugs than it fixes.
5. **When verifying a multi-part value** (major/minor, feet/inches, etc.), check every part the
   assertion actually depends on - a retry loop that only re-checks one part can converge on a
   result that's wrong in a part it never looked at.
6. **When a test fails in a way that doesn't match the obvious explanation, add temporary debug
   output and get real data** (a screenshot, a file-logged value trace) before changing the fix -
   several of the issues above look identical to ordinary flakiness from the failure message
   alone, but have entirely different root causes and fixes.
