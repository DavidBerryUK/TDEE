import SwiftUI

// Animation constants
private let containerAnimationDuration = 0.3
private let contentFadeDuration = 0.15
private let contentFadeDelay = 0.10

struct UIExpanderView<Content: View>: View {
    @Binding var isExpanded: Bool

    @State private var isVisible = false
    @State private var hasHeight = false

    let content: Content

    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = isExpanded
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            if hasHeight {
                VStack(alignment: .leading, spacing: 0) {
                    content
                }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + contentFadeDuration) {
                    guard !isExpanded else { return }

                    withAnimation(.easeInOut(duration: containerAnimationDuration)) {
                        hasHeight = false
                    }
                }
            }
        }
    }
}

// New UIExpanderViewV2 based on assumptions
struct UIExpanderViewV2<Content: View>: View {
    @Binding var isExpanded: Bool

    @State private var isVisible = false
    @State private var hasHeight = false

    let content: Content

    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = isExpanded
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            if hasHeight {
                VStack(alignment: .leading, spacing: 0) {
                    content
                }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + contentFadeDuration) {
                    guard !isExpanded else { return }

                    withAnimation(.easeInOut(duration: containerAnimationDuration)) {
                        hasHeight = false
                    }
                }
            }
        }
    }
}

#Preview("Toggle Control") {
    @Previewable @State var isContentExpanded = false

    VStack(alignment: .leading, spacing: 16) {
        Rectangle()
            .fill(Color.blue)
            .frame(height: 50)
            .cornerRadius(8) // Added corner radius

        Toggle(isOn: $isContentExpanded.animation(.easeInOut(duration: containerAnimationDuration))) { // apply animation to toggle state
            Text("Expand Content")
        }

        UIExpanderViewV2(isExpanded: $isContentExpanded) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Header")
                    .font(.headline)
                
                Text("This is the main body content. It provides detailed information about the topic being discussed. You can add more text here to make it more complex.")
                    .font(.body)
                
                Text("Footer")
                    .font(.subheadline)
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        
        Rectangle()
            .fill(Color.green)
            .frame(height: 50)
            .cornerRadius(8) // Added corner radius

        Spacer()

       
        
    }
    .padding()
}
