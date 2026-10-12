# Story 007: Share Button Fix

**Objective:** Fix or remove the non-functional share button in the main screen's toolbar.

**Motivation:** The share button in the top-right toolbar has an empty action closure, making it non-functional. This creates a confusing user experience - users may tap it expecting it to work, or wonder why it's there.

## Current State

```swift
ToolbarItem(placement: .topBarTrailing) {
    Button {
    } label: {
        Image(systemName: "square.and.arrow.up")
    }
    .accessibilityLabel("Share current settings")
}
```

The button:
- Shows a share icon (square with up arrow)
- Has accessibility label "Share current settings"
- Has no action when tapped

## Options

### Option A: Remove the Button (Recommended)
**Pros:**
- Cleanest solution
- No confusion for users
- Faster implementation

**Cons:**
- Users lose ability to share settings (but it wasn't working anyway)
- Would need to be re-implemented later if share functionality is added

### Option B: Implement Share Functionality
**Pros:**
- Actually implements the intended feature

**Cons:**
- Requires defining what gets shared (profile data? current settings? calculations?)
- Requires UI for sharing (ActivityViewController)
- More complex implementation

### Option C: Replace with Settings Button
**Pros:**
- Useful navigation action
- Common pattern in iOS apps

**Cons:**
- May conflict with existing navigation patterns

## Recommendation

**Remove the button for now.** The app already has a navigation menu (top-left "three lines" button) that accesses system settings. The share button is non-functional and shouldn't be shown.

If share functionality is desired, it should be implemented as a proper feature (Story 008 or similar) with:
1. Definition of what gets shared
2. Implementation of the share UI
3. Testing

## Implementation

**File to modify:** `ContentView.swift`

**Changes:**
- Remove the entire `ToolbarItem(placement: .topBarTrailing)` block

## Testing Checklist

- [ ] Share button removed from toolbar
- [ ] Other toolbar items (navigation menu) still work
- [ ] Layout looks balanced without the share button

## Dependencies

None - this is a standalone fix.
