import SwiftUI

struct UILayoutExpandingPanel<HeaderView: View, ContentView: View>: View {
    
    @Binding var isOpen: Bool
    @State private var isVisible: Bool
    
    let headerView: () -> HeaderView
    let contentView: () -> ContentView
    
    // MARK: - Animations (single source of truth)
    
    private let expandAnimation = Animation.spring(
        response: 0.45,
        dampingFraction: 0.85
    )
    
    private let collapseAnimation = Animation.easeInOut(duration: 0.2)
    
    // MARK: - Init
    
    init(
        isOpen: Binding<Bool>,
        @ViewBuilder header: @escaping () -> HeaderView,
        @ViewBuilder content: @escaping () -> ContentView
    ) {
        self._isOpen = isOpen
        self.headerView = header
        self.contentView = content
        _isVisible = State(initialValue: isOpen.wrappedValue)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {

            headerView()

            if isOpen || isVisible {
                contentView()
                    .opacity(isVisible ? 1 : 0)
                    .frame(maxHeight: isVisible ? .infinity : 0)
                    .clipped()
            }
        }
        .accessibilityElement(children: .contain)
        .onChange(of: isOpen) { _, newValue in

            if newValue {
                // EXPAND: insert collapsed animate open
                isVisible = false

                withAnimation(expandAnimation) {
                    isVisible = true
                }

            } else {
                // COLLAPSE: fade out then height collapses
                withAnimation(collapseAnimation) {
                    isVisible = false
                }
            }
        }
    }
}
