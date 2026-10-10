# Plan: Story 003 - Navigate from Macro Split to Macro Options

## Summary

Add a "Manage Presets" button in the expanded Macro Split section that navigates to the Macro Options list.

## Implementation Steps

### 1. Verify existing routes and views

**File:** `ContentView.swift`
- Confirm `.maintainMacroConfig` route exists and loads `MacroOptionsListViewPage`

**File:** `Enums/EnumAppRoute.swift`
- Confirm `case maintainMacroConfig` route exists

### 2. Add navigation button to SectionMacroSplit

**File:** `ViewSections/SectionMacroSplit.swift`

Add a button in the `editorView` that:
- Shows "Manage Presets" text with a chevron icon
- Uses `NavigationLink(value: EnumAppRoute.maintainMacroConfig)` to navigate
- Is positioned at the bottom of the expanded area

**Current structure:**
```swift
editorView: {
    VStack(spacing: 0) {
        SectionEditorMacroMix(macroMix: macroMix)
        SectionMacroMixResults(calculationResults: calculationResult)
            .padding(.top, Spacing.medium)
            .padding(.bottom, Spacing.small)
    }
}
```

**Add a NavigationLink wrapper or Button that pushes the route:**
```swift
NavigationLink(value: EnumAppRoute.maintainMacroConfig) {
    Text("Manage Presets")
        .foregroundColor(.accentColor)
}
```

Or use a button that calls `path.append(.maintainMacroConfig)` if using programmatic navigation.

## Files to Modify

1. `ViewSections/SectionMacroSplit.swift` - Add navigation button in editorView
2. `ContentView.swift` - Verify route configuration (likely no change needed)
3. `Enums/EnumAppRoute.swift` - Verify route exists (likely no change needed)

## Testing

1. Run the app
2. Tap Macro Split to expand it
3. Verify "Manage Presets" button appears
4. Tap the button
5. Verify Macro Options list appears
