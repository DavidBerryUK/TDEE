# Story 003: Navigate from Macro Split to Macro Options

**Objective:** Add a way to navigate from the expanded Macro Split section to the Macro Options list where users can view, add, and edit custom macro presets.

**Motivation:** Users need an easy way to access the macro mixer and manage their custom macro presets without having to use the settings menu. The Macro Split section is where users interact with macros daily, so it makes sense to provide direct access to the full macro configuration from there.

## Current Behavior

- Macro Split section shows current macro selection via a picker wheel
- Macro Options list (accessible via Settings > Maintain Macros) lists all available presets
- No direct navigation from Macro Split section to Macro Options
- Users must go through Settings to manage custom macros

## Expected Behavior

- Tapping the Macro Split section header (or a chevron icon) navigates to the Macro Options list
- From the Macro Options list, users can:
  - View all available macro presets
  - Add new custom macros using the mixer
  - Edit existing macros
- Changes to macro presets are immediately available in the Macro Split picker

## Open Questions

- Should the navigation be from the section header or a dedicated button?
answer: it should be a dedicated button int he xpanded area.
- Should the section expand when tapped, or does navigation take precedence?
answer: the area will already be expanded:

## Decisions

- Add a chevron/right arrow icon to the right side of the Macro Split section title
answer: no - this should be a button in the expanded area
- Tapping the title area or chevron navigates to the Macro Options list
- Keep expansion behavior for the section (toggle detail view)

## Files to Modify

- `ViewSections/SectionMacroSplit.swift` - Add navigation destination
- `ContentView.swift` - Verify `.maintainMacroConfig` route is configured
- `Enums/EnumAppRoute.swift` - Verify route exists (may need to add)

## Dependencies

- None
