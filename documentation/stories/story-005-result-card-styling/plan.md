# Implementation Plan: Story 005 - Result Card Styling

## Files to Modify

### `ViewCards/UICardNumericResult.swift`

**Changes:**
- Add background fill: `.background(Color.gray.opacity(0.05))`
- Optionally add shadow for depth
- Keep existing stroke border

## Implementation Steps

1. **Add background fill** to the card
   ```swift
   .background(
       RoundedRectangle(cornerRadius: 12)
           .fill(Color.gray.opacity(0.05))
   )
   ```

2. **Optionally add shadow** for depth
   ```swift
   .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
   ```

3. **Test visually** in Xcode preview

## Testing Checklist

- [ ] Cards have subtle background
- [ ] Numbers remain legible
- [ ] Visual hierarchy is clear
- [ ] Cards work well in groups
