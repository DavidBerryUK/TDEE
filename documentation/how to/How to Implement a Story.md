# How to Implement a Story

This document describes the process for implementing a story in the SimpleTest iOS project.

## 1. Ensure code is merged into `develop`

Update to the latest `develop` branch before doing anything else.

```bash
git checkout develop
git pull
```

Check `git status` here too. Uncommitted changes sitting on the branch are either stray work-in-progress or something that needs investigating before proceeding.

**Why first:** Starting from a clean `develop` ensures you're working with the latest code and avoid merge conflicts later.

## 2. Create an appropriate feature branch

**This step is mandatory.** Do not make any code changes on `develop` directly.

```bash
git checkout develop
git pull
git checkout -b features/story-<NNN>-<short-slug>
```

E.g. `features/story-003-macro-options-nav` for this story.

### Branch naming convention

Use the format: `features/story-<NNN>-<short-slug>`

Examples:
- `features/story-003-macro-options-nav`
- `features/story-004-age-picker-defaults`

The slug should be kebab-case and describe the story's focus.

Mark this story as `In Progress` in `documentation/stories/README.md`'s Status column at this point — **before any other code changes** — so nobody else starts the same story in parallel.

**Why mandatory:** Feature branches ensure each story's changes are isolated, testable, and can be reviewed properly before merging into `develop`.

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

## 10. Stage, commit, and merge back into `develop`

### Important: Use comments to keep the user informed

Git operations can take 5+ minutes due to permission checks. Always **explain what you're about to do** before running git commands:

```swift
// Think step by step
// 1. Stage all changes with git add
// 2. Commit with a descriptive message
// 3. Switch to develop and pull latest
// 4. Merge the feature branch
// 5. Delete the feature branch
```

Or in documentation:

> **Next**: I'll stage all changes, commit them, switch to `develop`, pull the latest, merge the feature branch, and delete it. This typically takes 5-10 minutes due to permission checks.

**What not to do**:
- Don't just run `git add . && git commit ...` without explanation
- Don't chain multiple git commands without warning the user
- Don't surprise the user with a 5-minute wait

**What to do instead**:
- **Perform analysis first**: Check `git status`, review diff with `git diff`
- **Explain the plan**: "I'm about to stage and commit these changes"
- **Warn about timing**: "This will take 5+ minutes due to permission checks"
- **Run commands one at a time**: Let the user see progress

### Example workflow with comments:

```bash
# 1. Stage all changes
git add .

# 2. Check what will be committed
git status
git diff --cached

# 3. Commit with descriptive message
git commit -m "Implement story-<NNN>: <description>"

# 4. Switch to develop branch
git checkout develop

# 5. Pull latest from remote
git pull

# 6. Merge feature branch
git merge --no-ff features/story-<NNN>-<short-slug> -m "Merge features/story-<NNN>-<short-slug> into develop"

# 7. Delete feature branch
git branch -d features/story-<NNN>-<short-slug>
```

## 11. Self-review this how-to

Once the story is merged, look back and ask whether this file held up. If anything was worked around, discovered late, or turned out not to matter, edit this file now.
