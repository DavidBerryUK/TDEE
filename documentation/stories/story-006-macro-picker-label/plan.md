# Implementation Plan: Story 006 - Macro Picker Label

## Files to Modify

### `ViewSections/SectionMacroSplit.swift`

**Changes:**
- Add a label above the `SectionEditorMacroMix` picker
- Use `.font(.callout)` with `.weight(.medium)` and `.foregroundColor(.secondary)`

## Implementation Steps

1. Add label above the picker in the editorView:
   ```swift
   VStack(spacing: 0) {
       Text("Current Selection")
           .font(.callout)
           .weight(.medium)
           .foregroundColor(.secondary)
           .padding(.bottom, 8)
       
       SectionEditorMacroMix(macroMix: macroMix)
       // ... rest of content
   }
   ```

2. Test in Xcode preview

## Testing Checklist

- [ ] Label appears when section is expanded
- [ ] Label is visually distinct but not overpowering
- [ ] Layout looks balanced
