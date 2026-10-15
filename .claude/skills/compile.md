# compile

Compile the SimpleTest iOS app using Xcode.

## Usage

When the user asks to compile, build, or run the app, use this skill to execute the compilation.

## Parameters

- **scheme**: The Xcode scheme to build (default: `SimpleTest`)
- **configuration**: The build configuration (default: `Debug`)
- **sdk**: The SDK to use (default: `iphonesimulator`)
- **destination**: The simulator destination (default: `platform=iOS Simulator,name=iPhone 17 Pro Max`)

## Command

```
/Applications/Xcode-27.2.0-Beta.3.app/Contents/Developer/usr/bin/xcodebuild \
  -project SimpleTest.xcodeproj \
  -scheme <scheme> \
  -configuration <configuration> \
  -sdk <sdk> \
  -destination '<destination>' \
  build
```

## Notes

- Uses Xcode-27.2.0-Beta.3 located at `/Applications/Xcode-27.2.0-Beta.3.app`
- Default destination is iPhone 17 Pro Max simulator
- For testing, append `test` instead of `build`
