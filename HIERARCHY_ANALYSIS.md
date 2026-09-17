# XCUITest Hierarchy Analysis

## The Problem

From the test logs, we can see:

1. The Picker **exists** in the accessibility hierarchy (XCUITest finds it at index 79)
2. The Picker has children (PickerWheel at index 80)
3. `app.pickers["agePicker"]` returns an empty query
4. Our scanning function iterates 165+ elements but doesn't find a match

## What We Know About the Hierarchy

### SwiftUI Structure
```
UILayoutSectionView (accessibilityId: "sectionAge", children: .contain)
  └── VStack
      └── SectionEditorAge (accessibilityId: "editorAge", children: .contain)
          └── UIWheelPickerAgeView
              └── HStack
                  └── Picker (accessibilityId: "agePicker", label: "Age picker")
                      └── PickerWheel (child element)
```

### XCUITest Observations from Logs
```
00:07.667 Find the Any (Element at index 0)
...
00:14.472 Find the Picker (Element at index 79)
00:14.567 Find the Picker (this might be the query from our function)
00:14.658 Find the Any (Element at index 80)  -- PickerWheel child
```

The picker exists at index 79, and its child is at index 80.

## Key Questions

### Question 1: Does the Picker appear as `.picker` type?

**Yes** - We see "Find the Picker" in the logs, which means XCUITest recognizes it as a picker.

### Question 2: What is the Picker's identifier?

**This is the question.** If the Picker's `identifier` property is "agePicker", then why doesn't `app.pickers["agePicker"]` find it?

### Question 3: Is the Picker being merged into its parent?

Looking at `SectionEditorAge`:
```swift
.accessibilityElement(children: .contain)
```

This makes the parent view an accessibility element that contains its children. This could mean:
- The parent becomes the accessibility element
- The children may or may not be separately accessible

But `UIWheelPickerAgeView` also has:
```swift
.accessibilityIdentifier("agePicker")
```

The question is: **Which element gets the identifier?** The Picker itself, or is it lost in the hierarchy?

### Question 4: What does `.accessibilityElement(children: .contain)` do?

From Apple's docs:
- `.contain` - The accessibility element contains its children. Children are accessible separately.

So with `.contain`:
- The parent is an accessibility element
- The children are ALSO accessibility elements

This should mean the Picker should still be accessible...

### Question 5: Why does scanning work but identifier lookup doesn't?

When we iterate `app.descendants(matching: .any)`, we find 165+ elements.
When we check `element.elementType == .picker`, we should find the picker.

The issue might be:
1. The Picker's identifier is NOT "agePicker" at runtime
2. The identifier is set but not accessible via XCUIElement.identifier
3. There's a timing issue

## Hypothesis

The `.accessibilityIdentifier("agePicker")` is being set on the SwiftUI Picker view, but when SwiftUI renders it with `.pickerStyle(.wheel)`, the resulting XCUIElement may not have that identifier properly propagated.

**Why?** Because `.pickerStyle(.wheel)` creates a `UIPickerView` which has its own accessibility implementation. SwiftUI's accessibility identifier may be getting overridden or not applied.

## Investigation Plan

To prove this hypothesis, we need to:

1. Create a minimal SwiftUI app with a Picker
2. Run XCUITest and print all properties of the Picker element
3. Check if the identifier matches what we set

## Alternative: Use Accessibility Label Instead

The `.accessibilityLabel("Age picker")` might be more reliably propagated. Let's try:

```swift
// Instead of:
app.pickers["agePicker"]

// Try:
app.descendants(matching: .picker)
    .first { $0.label == "Age picker" }
```

But we already tried this and it didn't work...

## Conclusion from Analysis

The fundamental issue appears to be:

**SwiftUI's `.pickerStyle(.wheel)` combined with nested accessibility elements causes the accessibility identifier to not be properly exposed to XCUIElement.**

The Picker exists (we can see it), but its `identifier` property is not "agePicker" as we set it.

## What We Can Try Next

1. **Use accessibilityValue** instead of accessibilityIdentifier
2. **Remove nested accessibility elements** and see if that helps
3. **Use position-based matching** (find picker at known index after known element)
4. **Use UIAccessibilityCustomAction** to expose test metadata
