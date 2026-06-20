import SwiftUI

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
            content
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 8)
                .opacity(isVisible ? 1 : 0)
        }
        .frame(height: hasHeight ? nil : 0)
        .clipped()
        .onAppear {
            hasHeight = isExpanded
            isVisible = isExpanded
        }
        .onChange(of: isExpanded) { _, expanded in
            if expanded {

                // Expand first
                hasHeight = true

                // Then fade in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = true
                }

            } else {

                // Fade out first
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }

                // Collapse AFTER fade completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard !isExpanded else { return }

                    withAnimation(.easeInOut(duration: 0.3)) {
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

        Toggle(isOn: $isContentExpanded.animation(.easeInOut(duration: 0.3))) { // apply animation to toggle state
            Text("Expand Content")
        }

        UIExpanderView(isExpanded: $isContentExpanded) {
            Text(
                "This content can be expanded or collapsed based on the toggle."
                    + "\nIt demonstrates dynamic behavior in previews."
            )
            .font(.body)
            .lineLimit(3)
        }
        
        Rectangle()
            .fill(Color.green)
            .frame(height: 50)

        Spacer()
    }
    .padding()
}
