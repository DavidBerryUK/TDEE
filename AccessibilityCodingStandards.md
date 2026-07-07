# Accessibility Coding Standards

## Overview

This document outlines the coding standards and best practices for implementing accessibility features in the SimpleTest iOS application. All UI components must have proper accessibility labels and values to ensure compatibility with VoiceOver and other assistive technologies.

## Core Principles

1. **Every interactive UI element must have an accessibility label**
2. **Slider, picker, and input controls should provide accessibility values**
3. **Accessibility labels should be descriptive and concise**
4. **Accessibility values should communicate the current state**

## Accessibility Label Standards

### General Guidelines
- Labels should clearly describe what the control does or represents
- Use complete sentences when needed for clarity
- Keep labels under 100 characters
- Avoid generic terms like "button" or "control"
- Use the same terminology that users would naturally refer to

### Examples
```swift
// Good - descriptive and clear
.accessibilityLabel("Calorie adjustment slider")

// Good - specific to the control's purpose  
.accessibilityLabel("Macro split selection")

// Good - describes the action
.accessibilityLabel("Save profile settings")
```

### Controls That Require Labels
- Sliders (`.accessibilityLabel`)
- Pickers (`.accessibilityLabel`) 
- Buttons (`.accessibilityLabel`)
- Switches (`.accessibilityLabel`)
- Text fields (`.accessibilityLabel` + `.accessibilityValue`)
- Segmented controls (`.accessibilityLabel`)

## Accessibility Value Standards

### When to Use Accessibility Values
- Sliders that represent a numeric value
- Pickers with discrete values
- Any control where the current state is meaningful
- Progress indicators or status displays

### Examples
```swift
// Good - provides current value
.accessibilityValue("\(Int(model.calorieAdjustment)) calories")

// Good - provides current selection  
.accessibilityValue("Selected: \(selectedItem.name)")

// Good - provides status information
.accessibilityValue("Current weight: \(model.weight) kg")
```

## Specific Component Standards

### Sliders
```swift
Slider(value: $model.calorieAdjustment, in: 0...1000)
    .accessibilityLabel("Calorie adjustment slider")
    .accessibilityValue("\(Int(model.calorieAdjustment)) calories")
```

### Pickers
```swift
Picker("Macro Split", selection: $macroSplit.selectedMacroId) {
    ForEach(collection.items) { item in
        Text(item.name)
            .tag(item.id)
    }
}
.pickerStyle(.wheel)
.accessibilityLabel("Macro split selection")
.accessibilityValue("Selected: \(selectedItem.name)")
```

### Buttons
```swift
Button("Save Profile") {
    // action
}
.accessibilityLabel("Save profile settings")
```

### Switches
```swift
Toggle("Enable notifications", isOn: $notificationsEnabled)
    .accessibilityLabel("Enable notifications toggle")
    .accessibilityValue(notificationsEnabled ? "On" : "Off")
```

## Best Practices

1. **Consistency**: Use consistent naming patterns across all controls
2. **Context**: Include enough context to understand the control's purpose
3. **State Awareness**: For interactive elements, include current state information
4. **Testing**: Test accessibility features using VoiceOver
5. **Localization**: Ensure labels work well with localization (avoid hardcoding text where possible)
6. **Performance**: Accessibility labels are computed at runtime, so avoid expensive operations

## Validation Checklist

- [ ] All interactive controls have `accessibilityLabel`
- [ ] Numeric controls have `accessibilityValue` when appropriate  
- [ ] Labels are descriptive and meaningful
- [ ] Values accurately reflect current state
- [ ] No generic terms like "button" or "control"
- [ ] Labels are localized if needed
- [ ] Accessibility features tested with VoiceOver

## References

- [Apple Accessibility Documentation](https://developer.apple.com/accessibility/)
- [SwiftUI Accessibility Guide](https://developer.apple.com/documentation/swiftui/accessibility)
- [iOS Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

## Related Issues
This standard addresses issue #14 from the code review document: "No accessibility labels" across all UI components.