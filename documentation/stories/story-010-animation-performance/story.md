# Story 010: Animation Performance

**Objective:** Replace `DispatchQueue.main.asyncAfter` with SwiftUI's built-in animation system for better performance.

**Motivation:** The `UIExpanderView` uses `DispatchQueue.main.asyncAfter` to sequence animations (fade content in/out before expanding/collapsing the container). While functional, this approach:
1. Uses GCD instead of SwiftUI's native animation system
2. Could potentially cause jank with multiple simultaneous expansions
3. Is more complex than needed

## Current State

```swift
struct UIExpanderView<Content: View>: View {
    @Binding var isExpanded: Bool
    
    @State private var isVisible = false
    @State private var hasHeight = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if hasHeight {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .opacity(isVisible ? 1 : 0)
                    .transition(.move(edge: .top))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
        .animation(.easeInOut(duration: containerAnimationDuration), value: hasHeight)
        .onChange(of: isExpanded) { _, expanded in
            if expanded {
                // Expand container first
                withAnimation(.easeInOut(duration: containerAnimationDuration)) {
                    hasHeight = true
                }
                
                // Then fade content in
                DispatchQueue.main.asyncAfter(deadline: .now() + contentFadeDelay) {
                    guard isExpanded else { return }
                    withAnimation(.easeInOut(duration: contentFadeDuration)) {
                        isVisible = true
                    }
                }
            } else {
                // Fade out first
                withAnimation(.easeInOut(duration: contentFadeDuration)) {
                    isVisible = false
                }
                
                // Then collapse container
                DispatchQueue.main.asyncAfter(deadline: .now() + contentFadeDelay) {
                    guard !isExpanded else { return }
                    withAnimation(.easeInOut(duration: containerAnimationDuration)) {
                        hasHeight = false
                    }
                }
            }
        }
    }
}
```

## Expected State

Use SwiftUI's animation modifiers with proper timing to achieve the same effect.

## Implementation Approach

### Option A: Sequential Animations with Delay
Use SwiftUI's `animation` modifier with a custom animation that includes a delay.

### Option B: Staggered State Changes
Use a single `Animation` with a longer duration and different easing to simulate the staggered effect.

### Option C: Keyframe Animations
Use SwiftUI's `GeometryEffect` or `Animatable` for more complex animation control.

## Recommendation

**Option A: Use `Animation` with a custom timing curve.**

The key insight is that SwiftUI's `Animation` can be configured with a `delay` parameter. We can also chain animations by using `withAnimation` with different animations for different properties.

## Implementation

**File to modify:** `ViewCards/UIExpanderView.swift`

**Changes:**
- Replace `DispatchQueue.main.asyncAfter` with `Animation` delays
- Use `.animation(.easeInOut(duration: X).delay(Y), value: ...)` for delayed animations

## Testing Checklist

- [ ] Animations are smooth
- [ ] No jank with multiple sections expanding
- [ ] Animation sequence (container expands, then content fades) is preserved

## Dependencies

None - this is a standalone performance improvement.
