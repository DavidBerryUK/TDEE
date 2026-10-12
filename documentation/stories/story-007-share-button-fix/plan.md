# Implementation Plan: Story 007 - Share Button Fix

## Files to Modify

### `ContentView.swift`

**Changes:**
- Remove the share button toolbar item (lines 33-39 in original)

**Before:**
```swift
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button {
            path.append(.system)
        } label: {
            Image(systemName: "line.3.horizontal")
        }
        .accessibilityLabel("Open navigation menu")
    }

    ToolbarItem(placement: .topBarTrailing) {
        Button {
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Share current settings")
    }
}
```

**After:**
```swift
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button {
            path.append(.system)
        } label: {
            Image(systemName: "line.3.horizontal")
        }
        .accessibilityLabel("Open navigation menu")
    }
}
```

## Implementation Steps

1. Open `ContentView.swift`
2. Remove the trailing toolbar item
3. Test in preview

## Testing Checklist

- [ ] Share button removed
- [ ] Navigation menu still works
- [ ] Layout looks balanced
