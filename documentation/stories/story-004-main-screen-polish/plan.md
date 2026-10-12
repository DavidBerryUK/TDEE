# Implementation Plan: Story 004 - Main Screen Polish

## Files to Modify

### 1. `ViewsLayouts/UILayoutSectionView.swift`
**Changes:**
- Change spacing from `Spacing.small` (8pt) to `Spacing.medium` (12pt) in the header VStack

**Why:** Consistent spacing across all sections

### 2. `ContentView.swift`
**Changes:**
- Remove the share button toolbar item
- Remove the redundant `.toolbar(.visible, for: .navigationBar)` line (keep `.toolbarBackground(.hidden)`)

**Why:** The share button was non-functional; toolbar visible call was redundant with hidden background

### 3. `ViewSections/SectionMacroSplit.swift`
**Changes:**
- Add a title label above the macro picker in the editorView showing "Current Selection"
- Style the label with appropriate weight and color

**Why:** Make selected macro more prominent

### 4. `ViewCards/UICardNumericResult.swift` and `ViewSections/SectionMacroMixResults.swift`
**Changes:**
- Add optional `color` parameter to `UICardNumericResult`
- Use macro-specific colors for protein (red), carbs (blue), fats (mint)
- Keep gray background for generic results like calories

**Why:** Macro colors make the results more visually distinctive and reinforce the identity of each nutrient

### 5. `ViewCards/UIExpanderView.swift`
**Changes:**
- Replace `DispatchQueue.main.asyncAfter` with SwiftUI's `Animation` modifiers
- Use `.animation(.easeInOut(duration: X), value: isExpanded)` on opacity/frame changes

**Why:** More performant, idiomatic SwiftUI

### 6. `ViewsLayouts/UILayoutSectionView.swift`
**Changes:**
- Add `.scrollFocus` modifier or similar when `isExpanded` changes to `true`

**Why:** Auto-scroll to keep active fields visible

## Implementation Order

1. **Share button removal** - Quick cleanup
2. **Spacing fix** - Quick, foundational change
3. **Toolbar background** - Quick cleanup
4. **Result card background** - Visual improvement, independent
5. **Macro picker label** - Improves clarity
6. **Animation replacement** - Performance improvement
7. **Focus management** - Deferred to Story 011

## Testing Checklist

- [x] All sections have consistent spacing
- [x] Share button removed
- [x] Toolbar background renders correctly (transparent)
- [x] Macro selection has "Current Selection" label
- [x] Result cards have subtle gray background
- [x] Animations are smooth (no DispatchQueue)
- [ ] Focus management - deferred to Story 011
