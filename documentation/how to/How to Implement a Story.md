# How to Implement a Story

This document describes the process for implementing a story in the SimpleTest iOS project.

## 1. Ensure code is merged into `main` or `feature/fixes`

Update to the latest branch before doing anything else. This project uses a snagging workflow where finished stories are merged into `features/fixes` rather than directly to `main`.

```bash
git checkout features/fixes
git pull
```

Check `git status` here too. Uncommitted changes sitting on the branch are either stray work-in-progress or something that needs investigating before proceeding.

## 2. Create an appropriate feature branch

```bash
git checkout -b features/story-<NNN>-<short-slug>
```

E.g. `features/story-003-age-picker-defaults` for a story about age picker defaults.

Mark this story as `In Progress` in `documentation/stories/README.md`'s Status column at this point — before any other code changes — so nobody else starts the same story in parallel.

## 3. Ensure current source tests run

Confirm the baseline is green on this fresh branch before touching anything.

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug test
```

Or run tests via Xcode's test navigator.

If this baseline is already red, stop and fix or flag that first — don't let a pre-existing failure get absorbed into this story's own commit.

## 4. Check dependency order and open questions

Stories must be built in dependency order. Check the story's own **Depends on** line against the `Status` column in `documentation/stories/README.md`. If any story it depends on is not `Done`, **stop and raise this clearly** — do not begin planning or implementation until it's resolved.

Then open the story's own file (`documentation/stories/story-<NNN>-<short-slug>/story.md`) and read its **Open questions** section.

- **If it has open questions**: resolve them with the person who owns the story before writing any code.
- **If it says "None outstanding at the decision level"**: proceed to planning.

## 5. Create a plan for the story

Write an implementation plan from the story's **Decisions** section. The plan should detail:
- Which files/components it touches
- What new code is needed
- How it fits existing patterns (e.g. "follows the pattern of `SectionEditorWeight`")

Before planning any change that touches calculation logic, review the relevant files in `Calculations/` and `ViewSections/` to understand the current flow.

Write the plan to `documentation/stories/story-<NNN>-<short-slug>/plan.md`.

## 6. Ask the user to check the plan

Share the plan before writing code. Get an explicit go-ahead before moving to implementation.

## 7. Implement the plan, with tests

Write the code and its tests together. For UI changes, ensure they work in both simulator and on physical devices.

### Simulator vs. Device Configuration

If your story needs different default values for simulator vs. device, use runtime environment detection:

```swift
struct AppConfig {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }
    
    static let defaultWeight: Double = isSimulator ? 70.0 : 0.0
}
```

See `documentation/how to/How to Implement a Story.md` (this file) for more options.

## 8. Run all tests in the project

Run the full test suite to confirm nothing regressed:

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug test
```

## 9. Update the story, its README, and this how-to

- In the story file itself, note that it's been implemented.
- In `documentation/stories/README.md`, reflect that this story is done.
- If anything about this process turned out to be wrong, update this file too.

## 10. Stage, commit, and merge back into `features/fixes`

```bash
git add .
git commit -m "Implement story-<NNN>: <description>"
git checkout features/fixes
git pull
git merge --no-ff features/story-<NNN>-<short-slug> -m "Merge features/story-<NNN>-<short-slug> into features/fixes"
git branch -d features/story-<NNN>-<short-slug>
```

## 11. Self-review this how-to

Once the story is merged, look back and ask whether this file held up. If anything was worked around, discovered late, or turned out not to matter, edit this file now.
