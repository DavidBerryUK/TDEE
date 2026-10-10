# How to Implement a Story

This document describes the process for implementing a story in the SimpleTest iOS project.

## Overview

This workflow uses Git feature branches for isolation and a user-in-the-loop approach to ensure quality. All changes are made on feature branches and merged into `develop` only after user approval at key checkpoints.

---

## Workflow at a Glance

```
develop --> feature branch --> docs --> implement --> user test --> commit & merge
```

---

## 1. Prepare: Ensure code is merged into `develop`

Update to the latest `develop` branch before doing anything else.

```bash
git checkout develop
git pull
```

Check `git status` here too. Uncommitted changes sitting on the branch are either stray work-in-progress or something that needs investigating before proceeding.

---

## 2. Create a feature branch

```bash
git checkout -b features/story-<NNN>-<short-slug>
```

E.g. `features/story-003-age-picker-defaults` for a story about age picker defaults.

**Agent note:** Use `features/` prefix, not `feature/`. The plural is intentional.

All story work (including documentation updates) happens on this branch. Do not work on `develop` directly.

---

## 3. Create story documentation

Before implementing any code, create the story documentation:

1. Update `documentation/stories/README.md` to mark this story as `In Progress`
2. Create `documentation/stories/story-<NNN>-<short-slug>/` directory
3. Create `story.md` with requirements, open questions, and implementation notes

See existing stories for templates and formatting.

---

## 4. Establish baseline: Run existing tests

Confirm the baseline is green on this fresh branch before touching anything.

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug test
```

Or run tests via Xcode's test navigator.

If this baseline is already red, stop and fix or flag that first — don't let a pre-existing failure get absorbed into this story's own commit.

---

## 5. Review story requirements

Stories must be built in dependency order. Check the story's own **Depends on** line against the `Status` column in `documentation/stories/README.md`. If any story it depends on is not `Done`, **stop and raise this clearly** — do not begin planning or implementation until it's resolved.

Then open the story's own file (`documentation/stories/story-<NNN>-<short-slug>/story.md`) and read its **Open questions** section.

- **If it has open questions**: resolve them with the person who owns the story before writing any code.
- **If it says "None outstanding at the decision level"**: proceed to planning.

---

## 6. Create an implementation plan

Write an implementation plan from the story's **Decisions** section. The plan should detail:
- Which files/components it touches
- What new code is needed
- How it fits existing patterns (e.g. "follows the pattern of `SectionEditorWeight`")

Before planning any change that touches calculation logic, review the relevant files in `Calculations/` and `ViewSections/` to understand the current flow.

Write the plan to `documentation/stories/story-<NNN>-<short-slug>/plan.md`.

### Agent-friendly plan checklist

When writing plans, consider:
- **File changes**: List exact file paths
- **New files**: Note if any need to be created
- **Pattern matching**: Reference similar existing implementations
- **Test locations**: Specify where tests should go

---

## 7. User review: Plan approval

**Checkpoint:** Before writing any code, share the plan with the user for approval.

Do not proceed to implementation until the user has signed off on the plan.

---

## 8. Implement the plan

**Think step by step.** Always begin your response with `Thought process:` followed by numbered reasoning, then `Answer:` for the final output. Be concise but thorough.

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

### Code quality checklist

- [ ] Code follows existing patterns
- [ ] Tests are written alongside implementation
- [ ] No TODOs left in code (use `// FIXME:` with explainers instead)
- [ ] New types follow Swift naming conventions
- [ ] Public APIs have documentation comments

---

## 9. User review: Test drive

**Checkpoint:** After implementation but before running tests, let the user test the changes manually in Xcode.

- Build and run the app in Xcode
- Test the new feature in the simulator
- Verify it works on a physical device if applicable

Do not proceed to automated testing until the user has confirmed the feature works as expected.

---

## 10. Run automated tests

Run the full test suite to confirm nothing regressed:

```bash
xcodebuild -project SimpleTest.xcodeproj -scheme SimpleTest -configuration Debug test
```

If tests fail:
- Fix the code or tests as appropriate
- Re-run until all tests pass
- Document any test skipped and why

---

## 11. Update documentation

- In the story file itself, note that it's been implemented
- In `documentation/stories/README.md`, reflect that this story is `Done`
- If anything about this process turned out to be wrong, update this file too

---

## 12. Commit and merge

```bash
git add .
git commit -m "Implement story-<NNN>: <description>"
git checkout develop
git pull
git merge --no-ff features/story-<NNN>-<short-slug> -m "Merge features/story-<NNN>-<short-slug> into develop"
git branch -d features/story-<NNN>-<short-slug>
```

### Agent-friendly git commands

- `git add .` stages all changes on the feature branch
- `--no-ff` ensures a merge commit is created (preserves branch history)
- Delete the feature branch after merging

---

## 13. Self-review this how-to

Once the story is merged, look back and ask whether this file held up. If anything was worked around, discovered late, or turned out not to matter, edit this file now.

---

## Common Patterns

### Adding a new configuration key

1. Add key to `ConfigKeys.swift`
2. Update `ProfileDefaults.swift` simulator and device methods
3. Update `ProfileViewModel.swift` with default value
4. Test in both simulator and device

### Adding a new UI view

1. Create view file in `ViewSections/`
2. Follow existing view patterns
3. Add tests in `SimpleTestTests/`
4. Test in Xcode preview and simulator

---

## Troubleshooting

### Merge conflicts

If merging back to develop produces conflicts:
1. Ensure develop is up to date: `git checkout develop && git pull`
2. Rebase or merge develop into your feature branch
3. Resolve conflicts, then re-run tests
4. Merge back to develop

### Test failures

If tests fail after implementation:
1. Identify whether the test or implementation is wrong
2. Fix accordingly
3. Re-run tests until all pass
4. Do not proceed with merge until tests are green
