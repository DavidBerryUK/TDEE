# git

Perform git operations for the TDEE iOS project.

## Usage

Use this skill for common git operations like status, commit, push, and pull.

## Important Notes

- **Remote is configured**: `origin` is `git@github.com:DavidBerryUK/TDEE.git`. Remote operations (push/pull/fetch) work over SSH; ensure your SSH key is set up before pushing or pulling.

## Commands

### Check Status
```
git status
```

### View Log
```
git log --oneline
```

### Add Files
```
git add <files...>
```

### Commit Changes
```
git commit -m "<commit message>"
```

### Add Remote (when needed)
```
git remote add origin <repository-url>
```

## Examples

- "run git status" → `git status`
- "show recent commits" → `git log --oneline`
- "add and commit changes" → `git add .` then `git commit -m "<message>"`
- "add origin remote" → `git remote add origin <url>`
