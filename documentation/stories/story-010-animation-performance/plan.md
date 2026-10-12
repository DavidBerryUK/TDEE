# Implementation Plan: Story 010 - Animation Performance

## Files to Modify

### `ViewCards/UIExpanderView.swift`

**Current approach:**
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + contentFadeDelay) {
    guard isExpanded else { return }
    withAnimation(.easeInOut(duration: contentFadeDuration)) {
        isVisible = true
    }
}
```

**New approach:**
```swift
withAnimation(.easeInOut(duration: contentFadeDuration).delay(contentFadeDelay)) {
    isVisible = true
}
```

## Implementation Steps

1. Remove all `DispatchQueue.main.asyncAfter` calls
2. Add `.delay()` to animations where timing sequence matters
3. Test animations are still correct

## Testing Checklist

- [ ] Animations are smooth
- [ ] No jank with multiple sections expanding
- [ ] Visual behavior unchanged
