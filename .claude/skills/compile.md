# compile

Compile the TDEE iOS app using Xcode.

## Usage

When the user asks to compile, build, or run the app, use this skill to execute the compilation.

## Parameters

- **scheme**: The Xcode scheme to build (default: `TDEE`)
- **configuration**: The build configuration (default: `Debug`)
- **sdk**: The SDK to use (default: `iphonesimulator`)
- **destination**: The simulator destination (default: `generic/platform=iOS Simulator`)

## Command

```
xcrun xcodebuild \
  -project TDEE.xcodeproj \
  -scheme <scheme> \
  -configuration <configuration> \
  -sdk <sdk> \
  -destination '<destination>' \
  build
```

## Notes

- Resolves Xcode **dynamically** via `xcrun` (the active toolchain from `xcode-select -p`), so it
  tracks whatever Xcode is installed — **no hardcoded path**. Xcode 27 ships as a *versioned* app
  (e.g. `/Applications/Xcode-27.2.0-Release.Candidate.app`), and there is **no plain
  `/Applications/Xcode.app`**, so never hardcode a versioned path here — it breaks on every release.
- To **pin a specific Xcode** instead of the active one, prefix with
  `DEVELOPER_DIR=<path>/Contents/Developer`, e.g.
  `DEVELOPER_DIR="$(xcode-select -p)" xcrun xcodebuild ...`.
- Default destination is **`generic/platform=iOS Simulator`** — it builds for *any* installed iOS
  simulator, so it never breaks when a named device's runtime isn't the "latest" one. The pitfall it
  avoids: `name=X` expands to `OS:latest`, and if `X` only exists on an older runtime, xcodebuild fails
  with *"Unable to find a device matching the provided destination specifier"* (e.g. a booted
  `iPhone 17 Pro Max` on iOS 27.0, while the 27.2 toolchain's "latest" has no 17 Pro Max).
- To target a **specific device**, pass a `name=` — add `OS=` to pin the runtime when the name exists on
  several (e.g. `platform=iOS Simulator,name=iPhone 17 Pro Max,OS=27.0`), or target an exact
  `id=<UDID>` (from `xcrun simctl list devices`).
- For testing, append `test` instead of `build`
