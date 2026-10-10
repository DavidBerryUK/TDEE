# Implementation Plan: Story 002 - Macro Split Visibility

## Problem Analysis

The Macro Split section has two parts:
1. `SectionMacroSplit` - Contains the editor (wheel picker) that shows when expanded
2. `SectionMacroMixResults` - Shows protein/carbs/fat cards (currently outside the expansion)

**Current Issue:** When the Macro Split section expands, the editor content pushes down but goes off-screen. The `SectionMacroMixResults` is in a separate `VStack` outside the expansion, so it doesn't move with the expansion.

## Root Cause

In `MainSectionMacroMix.swift`:
```swift
VStack(spacing: 0) {
    Divider()
    SectionMacroSplit(...)       // Expands/collapses
    Divider()
    SectionMacroMixResults(...)  // Stays in place (fixed below)
}
```

The `SectionMacroMixResults` should be **inside** the expanded content, not outside.

## Solution

### Option A: Move SectionMacroMixResults inside the expansion (Recommended)

Modify `MainSectionMacroMix.swift` to include `SectionMacroMixResults` in the expanded content:

```swift
var body: some View {
    VStack(spacing: 0) {
        Divider()
        SectionMacroSplit(macroMix: macroMix, sectionManager: sectionManager)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .clipped()
        
        // Only show results when expanded
        if sectionManager.macroMixExpanded {
            Divider()
            SectionMacroMixResults(calculationResults: calculationResult)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .clipped()
        }
    }
}
```

**Benefits:**
- Results appear immediately after expansion
- Results scroll into view with the rest of the content
- Clean, predictable behavior

### Option B: Add explicit scrolling to the expanded view

If the content is too long, wrap the editor in a `ScrollViewReader` and scroll to it when expanded (similar to `MainSectionCaloriesAndAdjustments`).

**Trade-offs:**
- More complex
- Requires id's and scrolling logic
- May not be necessary if content fits on screen

## Recommended Approach: Option A

**Files to modify:**
1. `SimpleTest/Pages/MainPage/MainSectionMacroMix.swift` - Restructure to show results inside expansion
2. `SimpleTest/ViewSections/SectionMacroSplit.swift` - May need to adjust padding if content is cramped

**Test steps:**
1. Build and run the app
2. Expand the Macro Split section
3. Verify protein/carbs/fat cards are visible below the editor
4. Verify scrolling works to see all content on smaller screens
