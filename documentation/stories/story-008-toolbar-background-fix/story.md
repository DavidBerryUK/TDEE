# Story 008: Toolbar Background Fix

**Objective:** Fix the conflicting toolbar background configuration in the main screen.

**Motivation:** The main screen has two toolbar background lines that appear contradictory:

```swift
.toolbarBackground(.hidden, for: .navigationBar)
.toolbar(.visible, for: .navigationBar)
```

One hides the background, the other makes it visible. This is confusing and may cause unexpected rendering behavior.

## Current State

In `ContentView.swift`:
```swift
.toolbarBackground(.hidden, for: .navigationBar)
.toolbar(.visible, for: .navigationBar)
```

## Analysis

The `.toolbarBackground(.hidden, for: .navigationBar)` line is likely:
1. Leftover from earlier development
2. An attempt to override system defaults
3. Unnecessary because the default behavior may already be correct

## Expected State

The toolbar should have one clear configuration. Let's evaluate:

### Option A: Remove Both Lines
Let the system use its default toolbar background.

**Pros:**
- Simplest solution
- Uses system defaults

**Cons:**
- May not match app's design intent

### Option B: Keep `.toolbar(.visible, for: .navigationBar)`
Explicitly show the toolbar background (letting the system decide the style).

**Pros:**
- Clear and intentional
- Works with system theming

**Cons:**
- None obvious

### Option C: Explicit Background Color
Set a specific background color:
```swift
.toolbarBackground(.visible, for: .navigationBar)
.toolbarBackground(Color.white, for: .navigationBar)
```

**Pros:**
- Full control over appearance

**Cons:**
- May conflict with dark mode

## Recommendation

**Remove the `.hidden` line and keep `.toolbar(.visible, for: .navigationBar)`.**

This is:
1. Minimal change
2. Clear intent (show toolbar)
3. Works with system theming

## Implementation

**File to modify:** `ContentView.swift`

**Changes:**
- Remove `.toolbarBackground(.hidden, for: .navigationBar)`

## Testing Checklist

- [ ] Toolbar background renders correctly
- [ ] Works in both light and dark mode
- [ ] No visual glitches

## Dependencies

None - this is a standalone fix.
