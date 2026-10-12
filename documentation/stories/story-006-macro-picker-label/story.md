# Story 006: Macro Picker Label

**Objective:** Add a clear label above the macro split picker to indicate the current selection.

**Motivation:** When the Macro Split section is expanded, users see a picker wheel with macro options, but there's no label indicating what they're selecting. This makes the UI slightly less intuitive, especially for new users.

## Current State

The macro split picker appears without any label:

```swift
editorView: {
    VStack(spacing: 0) {
        SectionEditorMacroMix(macroMix: macroMix)
        SectionMacroMixResults(calculationResults: calculationResult)
            .padding(.top, Spacing.medium)
            .padding(.bottom, Spacing.small)
        // Navigation button
    }
}
```

## Expected State

The picker should have a label above it:

```
┌─────────────────────────────────────────┐
│ Macro Split              [chevron down] │
├─────────────────────────────────────────┤
│                                         │
│ Current Selection                       │  ← New label
│ Modern Keto                             │  ← Current value
│                                         │
│ [Picker wheel with macro options]      │
│                                         │
│ Protein  40%  230g  Carbs  30%  173g  Fats  30%  78g  ← Results
│                                         │
│ [Customise]                             │
└─────────────────────────────────────────┘
```

## Implementation

**File to modify:** `ViewSections/SectionMacroSplit.swift`

**Changes:**
1. Add a `Text("Current Selection")` label above the picker
2. Style it with appropriate weight and color
3. Add appropriate spacing

## Design Considerations

### Label Style
- Font: `.callout` or `.subheadline`
- Weight: `.medium` or `.semibold`
- Color: `.secondary` or `.primary`

### Positioning
- Place between the section title area and the picker
- Add spacing: `Padding(.bottom, 8)` after label

## Testing Checklist

- [ ] Label is visible when Macro Split is expanded
- [ ] Label text is clear and legible
- [ ] Label doesn't interfere with picker interaction
- [ ] Layout looks balanced

## Dependencies

None - this is a standalone enhancement.
