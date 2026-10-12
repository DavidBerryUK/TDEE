# Implementation Plan: Story 009 - Section Spacing Consistency

## Files to Modify

### 1. `ViewsLayouts/UILayoutSectionView.swift`

**Change:** Spacing in header VStack
```swift
// Before
VStack(alignment: .leading, spacing: Spacing.small)

// After
VStack(alignment: .leading, spacing: Spacing.medium)
```

### 2. `MainSectionProfileInput.swift`

**Change:** Replace Divider pattern with consistent spacing
```swift
// Before
VStack(spacing: 0) {
    SectionGender(...)
    Divider()
    SectionAge(...)
    Divider()
    // ...
}

// After
VStack(spacing: Spacing.medium) {
    SectionGender(...)
    SectionAge(...)
    // ... no Dividers needed
}
```

## Implementation Steps

1. Update `UILayoutSectionView.swift` spacing
2. Update `MainSectionProfileInput.swift` spacing and remove Dividers
3. Test in preview

## Testing Checklist

- [ ] All sections have consistent spacing
- [ ] Layout looks balanced
- [ ] No visual glitches
