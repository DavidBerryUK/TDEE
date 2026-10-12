# Story 009: Section Spacing Consistency

**Objective:** Standardize section spacing across the main screen for visual consistency.

**Motivation:** There's inconsistent spacing between sections depending on which view they're in:
- Profile input sections use `VStack(spacing: 0)` with `Divider()` between each section
- Other sections use `Spacing.medium` (12pt) or `Spacing.small` (8pt)

This creates a slightly disjointed visual experience.

## Current State

### Profile Input Sections (`MainSectionProfileInput.swift`)
```swift
VStack(spacing: 0) {
    SectionGender(model: profile, sectionManager: sectionManager)
    Divider()
    SectionAge(model: profile, sectionManager: sectionManager)
    Divider()
    SectionHeight(model: profile, sectionManager: sectionManager)
    // ...
}
```

### Other Sections (`UILayoutSectionView.swift`)
```swift
VStack(alignment: .leading, spacing: Spacing.small) // 8pt
```

## Expected State

All sections should use consistent spacing.

## Options

### Option A: Use `Spacing.medium` (12pt) Everywhere
**Pros:**
- More modern, generous spacing
- Better visual separation
- Consistent with other UI elements

**Cons:**
- Slightly more vertical space usage

### Option B: Use `Spacing.small` (8pt) Everywhere
**Pros:**
- More compact
- Consistent with current `UILayoutSectionView`

**Cons:**
- May feel cramped

### Option C: Keep Divider Pattern for Profile Sections
Use spacing for most sections, but keep the divider pattern for profile sections to visually group them together.

**Pros:**
- Preserves visual grouping of profile sections

**Cons:**
- Still inconsistent

## Recommendation

**Option A: Use `Spacing.medium` (12pt) everywhere.**

This is the most consistent and modern approach. The 12pt spacing provides good visual separation without being too generous.

## Implementation

**Files to modify:**
1. `ViewsLayouts/UILayoutSectionView.swift` - Change `Spacing.small` to `Spacing.medium`
2. `MainSectionProfileInput.swift` - Remove `Divider()` and use `spacing: Spacing.medium`

## Testing Checklist

- [ ] All sections have consistent spacing
- [ ] Layout looks balanced
- [ ] No visual glitches

## Dependencies

None - this is a standalone polish story.
