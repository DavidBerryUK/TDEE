# Implementation Plan: Story 008 - Toolbar Background Fix

## Files to Modify

### `ContentView.swift`

**Changes:**
- Remove `.toolbarBackground(.hidden, for: .navigationBar)`

**Before:**
```swift
.toolbarBackground(.hidden, for: .navigationBar)
.toolbar(.visible, for: .navigationBar)
.toolbarTitleDisplayMode(.inline)
.navigationBarTitleDisplayMode(.inline)
.ignoresSafeArea(edges: .top)
```

**After:**
```swift
.toolbar(.visible, for: .navigationBar)
.toolbarTitleDisplayMode(.inline)
.navigationBarTitleDisplayMode(.inline)
.ignoresSafeArea(edges: .top)
```

## Implementation Steps

1. Open `ContentView.swift`
2. Remove the `.toolbarBackground(.hidden, for: .navigationBar)` line
3. Test in preview

## Testing Checklist

- [ ] Toolbar background renders correctly
- [ ] Works in both light and dark mode
- [ ] No visual glitches
