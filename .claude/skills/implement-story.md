# implement-story
Guide for implementing a story in the TDEE iOS project.

# Steps to Implement a Story

## 1. Update to `develop` branch
```bash
git checkout develop
git pull
```

## 2. Create feature branch
```bash
git checkout -b features/story-<NNN>-<short-slug>
```

## 3. Verify baseline tests pass
```bash
xcodebuild -project TDEE.xcodeproj -scheme TDEE -configuration Debug test
```

## 4. Read story and resolve open questions
Check `documentation/stories/story-<NNN>-<short-slug>/story.md`

## 5. Create implementation plan
Write plan to `documentation/stories/story-<NNN>-<short-slug>/plan.md`

## 6. Implement with tests
Write code and tests together.

## 7. Run full test suite
```bash
xcodebuild -project TDEE.xcodeproj -scheme TDEE -configuration Debug test
```

## 8. Update documentation
Mark story as done in `documentation/stories/README.md`

## 9. Merge to `develop`
```bash
git checkout develop
git pull
git merge --no-ff features/story-<NNN>-<short-slug>
git push origin develop
```
