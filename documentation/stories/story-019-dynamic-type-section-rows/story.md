# Story 019: Dynamic Type Section Rows

**Objective:** Keep the main screen's section rows readable at accessibility Dynamic Type sizes.

## Problem
At accessibility sizes (e.g. accessibility-extra-large), the label, value and chevron are squeezed into one HStack, so values break mid-word: Height "17 / 5 cm", Activity Level "Moder-ate Exer-cise", Body Fat "omit-ted", and the title "Percent-age".

## Acceptance Criteria
- At the default text size, the main screen looks the same as before.
- At accessibility sizes, no title or value breaks mid-word.
- Colours are unchanged (they come from the palette/theme).
- The full test suite passes.
