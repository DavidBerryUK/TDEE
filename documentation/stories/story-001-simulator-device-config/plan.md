# Plan: Simulator/Device Configuration

## Files to Create

1. `SimpleTest/Config/AppConfig.swift` - Main configuration entry point
2. `SimpleTest/Config/ConfigLoader.swift` - Loads and merges configuration sources
3. `SimpleTest/Config/ConfigKeys.swift` - Configuration key definitions
4. `SimpleTest/Config/ProfileDefaults.swift` - Model for profile defaults
5. `SimpleTest/Config/DefaultsSimulator.plist` - Simulator-specific defaults
6. `SimpleTest/Config/DefaultsDevice.plist` - Device-specific defaults

## Files to Modify

1. `SimpleTest/SimpleTestApp.swift` - Initialize config at app launch
2. `SimpleTest/ProfileViewModel.swift` - Use config defaults instead of hardcoded values

## Configuration Keys

| Key | Type | Simulator Default | Device Default |
|-----|------|------------------|----------------|
| gender | String (enum raw value) | "male" | "male" |
| age | Int | 25 | 16 |
| height | Double | 175.0 | 0.0 |
| weight | Double | 70.0 | 0.0 |
| activityLevel | String (enum raw value) | "moderateExercise" | "sedentary" |
| bodyFatPercentage | Double | 15.0 | 0.0 |

## Implementation Steps

### Step 1: Create ConfigKeys.swift

Define all configuration keys in one place:

```swift
struct ConfigKeys {
    static let gender = "gender"
    static let age = "age"
    static let height = "height"
    static let weight = "weight"
    static let activityLevel = "activityLevel"
    static let bodyFatPercentage = "bodyFatPercentage"
}
```

### Step 2: Create ProfileDefaults.swift

Model for profile defaults:

```swift
struct ProfileDefaults {
    let gender: Gender
    let age: Int
    let height: Double
    let weight: Double
    let activityLevel: ActivityLevel
    let bodyFatPercentage: Double
    
    static func simulator() -> ProfileDefaults {
        ProfileDefaults(
            gender: .male,
            age: 25,
            height: 175.0,
            weight: 70.0,
            activityLevel: .moderateExercise,
            bodyFatPercentage: 15.0
        )
    }
    
    static func device() -> ProfileDefaults {
        ProfileDefaults(
            gender: .male,
            age: 16,
            height: 0.0,
            weight: 0.0,
            activityLevel: .sedentary,
            bodyFatPercentage: 0.0
        )
    }
}
```

### Step 3: Create ConfigLoader.swift

Use `#if targetEnvironment(simulator)` to determine which defaults to load:

```swift
struct ConfigLoader {
    static func loadProfileDefaults() -> ProfileDefaults {
        #if targetEnvironment(simulator)
        return ProfileDefaults.simulator()
        #else
        return ProfileDefaults.device()
        #endif
    }
}
```

### Step 4: Create AppConfig.swift

Main entry point:

```swift
struct AppConfig {
    static let shared = AppConfig()
    
    let profileDefaults: ProfileDefaults
    
    private init() {
        self.profileDefaults = ConfigLoader.loadProfileDefaults()
    }
}
```

### Step 5: Create plist files (optional alternative to hardcoded)

If using plist approach instead of hardcoded defaults:

`DefaultsSimulator.plist`:
```xml
<dict>
    <key>gender</key><string>male</string>
    <key>age</key><integer>25</integer>
    <key>height</key><real>175.0</real>
    <key>weight</key><real>70.0</real>
    <key>activityLevel</key><string>moderateExercise</string>
    <key>bodyFatPercentage</key><real>15.0</real>
</dict>
```

`DefaultsDevice.plist`:
```xml
<dict>
    <key>gender</key><string>male</string>
    <key>age</key><integer>16</integer>
    <key>height</key><real>0.0</real>
    <key>weight</key><real>0.0</real>
    <key>activityLevel</key><string>sedentary</string>
    <key>bodyFatPercentage</key><real>0.0</real>
</dict>
```

### Step 6: Update ProfileViewModel

Change hardcoded defaults to use config:

```swift
// Before
var age: Int = 16
var weight: Double = 0
var height: Double = 0
var activityLevel: ActivityLevel = .sedentary

// After
var age: Int = AppConfig.shared.profileDefaults.age
var weight: Double = AppConfig.shared.profileDefaults.weight
var height: Double = AppConfig.shared.profileDefaults.height
var activityLevel: ActivityLevel = AppConfig.shared.profileDefaults.activityLevel
```

## Testing Strategy

1. Test in simulator - verify simulator defaults are applied
2. Test on physical device - verify device defaults are applied
3. Test configuration access from different parts of the app

## Configuration Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Plist files | Xcode-integrated, human-readable, runtime configurable | Adds bundle files, requires loading logic |
| Swift struct with compiler directives | Compile-time optimized, type-safe | Requires recompile to change values |
| JSON files | Lightweight, easy to edit remotely | Not Xcode-integrated, requires parsing |
| Build configurations (.xcconfig) | Native Xcode approach | Only for build settings, not runtime |

**Selected approach:** Swift struct with compiler directives - simplest approach that provides type safety and clear separation without external files.
