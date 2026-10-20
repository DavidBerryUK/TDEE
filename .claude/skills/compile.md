# compile

Compile the TDEE iOS app using Xcode.

## Usage

When the user asks to compile, build, or run the app, use this skill to execute the compilation.

## Parameters

- **scheme**: The Xcode scheme to build (default: `TDEE`)
- **configuration**: The build configuration (default: `Debug`)
- **sdk**: The SDK to use (default: `iphonesimulator`)
- **destination**: The simulator destination (default: `platform=iOS Simulator,name=iPhone 17 Pro Max`)

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
- Default destination is iPhone 17 Pro Max simulator
- For testing, append `test` instead of `build`
