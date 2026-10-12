# Story 011: Focus Management

**Objective:** Add automatic scrolling when sections expand and contain active input fields.

**Motivation:** When a user taps to edit a field in a collapsed section, the section expands but the keyboard may cover the active field. There's no automatic scrolling to ensure the field remains visible.

## Current State

- Tapping a section header expands the section
- If the section contains input fields, the keyboard may appear
- No automatic scrolling to position the active field

## Expected State

- When a section expands AND contains an active field, auto-scroll to keep the field visible
- Use `ScrollViewProxy` to scroll to the expanded section

## Implementation Approach

### Option A: Focus-aware Expansion
Detect when a field is focused and scroll to it when the section expands.

### Option B: Manual Scroll Trigger
Have each editor view notify when it's focused and needs scrolling.

### Option C: Scroll on Expand (Simpler)
When any section expands, scroll to keep it in view. This is simpler and covers most use cases.

## Recommendation

**Option C: Scroll on Expand.**

This is simpler and covers most cases. When the user taps a section to expand it, we can scroll to ensure the entire section is visible.

## Implementation

**File to modify:** `ViewsLayouts/UILayoutSectionView.swift`

**Changes:**
- Accept a `ScrollViewProxy` as a parameter
- When `isExpanded` changes to `true`, call `proxy.scrollTo(id, anchor: .top)`

**OR**

**File to modify:** Individual section files

**Changes:**
- Each section passes its `id` to `UILayoutSectionView`
- When expanded, scroll to that id

## Testing Checklist

- [ ] Expanding sections scroll into view
- [ ] Active fields are visible when section expands
- [ ] No unnecessary scrolling when section collapses
- [ ] Works on different screen sizes

## Dependencies

None - this is a standalone enhancement.
