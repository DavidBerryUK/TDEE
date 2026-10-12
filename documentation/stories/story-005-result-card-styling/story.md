# Story 005: Result Card Styling

**Objective:** Improve the visual styling of result cards to make them more visually distinct and aesthetically pleasing.

**Motivation:** The `UICardNumericResult` component currently uses only a stroke border with no background fill. This makes the cards less visually distinct against the white section background, especially when multiple cards are displayed together (e.g., in the macro breakdown).

## Current State

```swift
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color(red: 0.25, green: 0.75, blue: 0.75), lineWidth: 1)
)
```

The cards use:
- Teal-colored stroke (RGB: 0.25, 0.75, 0.75)
- No background fill
- Large title-style font for numbers
- Callout-style font for labels

## Expected State

The cards should have:
1. **Subtle background fill** - 5% gray opacity for depth
2. **Macro-specific colors** - Protein (red), Carbs (blue), Fats (green)
3. **Slightly thicker border** - 1.5pt for better visibility
4. **Consistent corner radius** - 12pt (already consistent)

## Design Options

### Option A: Gray Background (Conservative)
- Background: `Color.gray.opacity(0.05)`
- Border: Current teal stroke (1pt)
- **Pros:** Minimal visual change, safe for production
- **Cons:** Less visually exciting

### Option B: Macro-Specific Colors (Recommended)
- Background: Macro color with 10% opacity
  - Protein: `Color.red.opacity(0.1)`
  - Carbs: `Color.blue.opacity(0.1)`
  - Fats: `Color.green.opacity(0.1)` or `Color.mint.opacity(0.1)`
- Border: Same macro color (1pt)
- **Pros:** Visually distinctive, reinforces macro identities
- **Cons:** More visual change, needs testing

### Option C: Card with Shadow (Most Dramatic)
- Background: `Color.white`
- Shadow: Subtle drop shadow
- Border: 1pt system gray
- **Pros:** Most visually distinct, familiar card pattern
- **Cons:** May compete with section card background

## Implementation

**File to modify:** `ViewCards/UICardNumericResult.swift`

**Changes:**
1. Add background fill using `.background()` modifier
2. Consider adding shadow for depth
3. Keep existing stroke border or replace with fill-only approach

## Testing Checklist

- [ ] Cards are visually distinct from background
- [ ] Multiple cards in a row display well together
- [ ] Numbers remain legible with background
- [ ] Visual style matches app's overall design language
- [ ] Works well in both light and dark mode

## Dependencies

None - this is a standalone styling story.
