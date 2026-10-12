# Story 004: Main Screen Polish

**Objective:** Address several small UI/UX issues on the main screen to improve polish, consistency, and user experience.

**Motivation:** The app has a solid foundation but has several small inconsistencies and issues that detract from the overall user experience. Addressing these will make the app feel more professional and refined.

## UI/UX Issues to Address

### 1. Inconsistent Section Spacing
**Issue:** Profile input sections use `VStack(spacing: 0)` with `Divider()` between each section, while other sections use `VStack(spacing: 8)` for spacing. This creates visual inconsistency.

**Expected Behavior:** Consistent spacing throughout the app.

### 2. Share Button Has No Action
**Issue:** The share button in the top-right toolbar has an empty closure - no action is performed when tapped.

**Expected Behavior:** Either implement the share functionality or remove the button entirely.

### 3. Toolbar Background Configuration Conflict
**Issue:** The toolbar has both `.hidden` and `.visible` background settings which appear contradictory.

```swift
.toolbarBackground(.hidden, for: .navigationBar)
.toolbar(.visible, for: .navigationBar)
```

**Expected Behavior:** Clear, intentional toolbar background configuration.

### 4. Macro Split Picker Missing Visual Hierarchy
**Issue:** The macro split picker doesn't clearly show the selected value. The picker wheel is present but there's no label above it or other visual emphasis on the current selection.

**Expected Behavior:** The selected macro preset is clearly visible and prominent.

### 5. Result Cards Lack Background Fill
**Issue:** `UICardNumericResult` uses only a stroke border with no background fill, making the cards less visually distinct.

**Expected Behavior:** Cards have subtle background fill to make them "pop" more against the white section background.

### 6. Animation Performance with Multiple Sections
**Issue:** `UIExpanderView` uses `DispatchQueue.main.asyncAfter` which could potentially cause jank if many sections expand simultaneously.

**Expected Behavior:** Smooth animations even when multiple sections expand at once.

### 7. Missing Focus Management
**Issue:** When a section expands and the user is editing, there's no automatic keyboard scrolling or focus management.

**Expected Behavior:** Scrolling properly positions the keyboard and active fields.

## Decisions

| Issue | Decision | Rationale |
|-------|----------|-----------|
| Spacing | Use `Spacing.medium` (12pt) for all section spacing | Modern UI with slightly larger spacing for better readability |
| Share Button | **Remove the button entirely** | No share functionality implemented; removing non-functional UI |
| Toolbar Background | Keep `.toolbarBackground(.hidden, for: .navigationBar)` | Makes the navigation bar transparent, matching app design intent |
| Macro Picker | **Add "Current Selection" label** above the picker | Improves visual hierarchy and makes selection clear |
| Result Cards | **Add subtle gray background fill (5% opacity)** | Makes cards visually distinct without being distracting |
| Animations | **Replace `DispatchQueue` with SwiftUI's built-in `Animation`** | More performant and idiomatic SwiftUI |
| Focus Management | **Deferred to Story 011** | Requires ScrollViewProxy integration; better as separate story |

## Open Questions (Resolved)

- **Should the share button be replaced with a settings/profile button instead?** - NO. The share button was non-functional, so it was simply removed. If share functionality is desired, it should be implemented as a new story with proper requirements.
- **Should result cards use the macro colors (red for protein, blue for carbs, green for fats) instead of gray?** - NO. Gray (5% opacity) was chosen for subtlety; using macro colors might be too visually busy for a background.
- **Should keyboard handling be implemented via `UIScrollView` observer or SwiftUI's newer focus API when available?** - DEFERRED. This requires more complex integration with ScrollViewProxy and will be addressed in Story 011.

## Implementation Notes

- Follow existing patterns in `ViewSections/` and `ViewsValueEditors/`
- Use existing `Spacing` and `UIStyle` constants
- Test on both iPhone SE (small screen) and iPhone Pro Max (large screen)

## Dependencies

None - this is a standalone polish story.
