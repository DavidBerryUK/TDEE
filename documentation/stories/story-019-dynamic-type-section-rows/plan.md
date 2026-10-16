# Plan: Story 019

1. `UILayoutSectionView`: read `@Environment(\.dynamicTypeSize)`. When `isAccessibilitySize`, render the header as a VStack: icon + title + chevron on the first line, then the summary value on its own full-width line. Otherwise keep the original single HStack.
2. Pull the title and chevron into private computed views so both layouts share them.
3. `UISectionSummaryValueHeight`: add `.fixedSize()` to the numeric major/minor values so digits never split.
4. No `minimumScaleFactor` is needed. No colour changes.
5. Verify with `xcrun simctl ui booted content_size accessibility-extra-large`. Screenshots are in `screenshots/` (before-ax, after-ax, after-default).
6. Run the full test suite.
