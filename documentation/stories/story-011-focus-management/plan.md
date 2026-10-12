# Implementation Plan: Story 011 - Focus Management

## Files to Modify

### `ViewsLayouts/UILayoutSectionView.swift`

**Changes:**
- Add `ScrollViewProxy` parameter
- Add section `id` parameter
- Call `proxy.scrollTo()` when `isExpanded` changes to `true`

## Implementation Steps

1. Add parameters to `UILayoutSectionView`:
   - `proxy: ScrollViewProxy`
   - `sectionId: String`

2. In the `onChange` for `isExpanded`, call:
   ```swift
   if isExpanded {
       Task {
           try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s delay
           proxy.scrollTo(sectionId, anchor: .top)
       }
   }
   ```

3. Update all call sites to pass the proxy and id

## Testing Checklist

- [ ] Expanding sections scroll into view
- [ ] Active fields are visible
- [ ] No unnecessary scrolling
