import SwiftUI

struct TestHostContainer<
    Content: View,
    InputView: View,
    ValueView: View
>: View {
    
    let title: String
    let instructions: String
    
    let content: Content
    let inputView: InputView
    let valueView: ValueView
    
    init(
        title: String,
        instructions: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder inputView: () -> InputView = { EmptyView() },
        @ViewBuilder valueView: () -> ValueView = { EmptyView() }
    ) {
        self.title = title
        self.instructions = instructions
        self.content = content()
        self.inputView = inputView()
        self.valueView = valueView()
    }
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text(instructions)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Input (only renders if not EmptyView)
                if !(inputView is EmptyView) {
                    sectionContainer(title: "Input") {
                        inputView
                    }
                }
                
                sectionContainer(title: "Hosted Control") {
                    content
                }
                
                // Value display
                if !(valueView is EmptyView) {
                    sectionContainer(title: "Value") {
                        valueView
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sectionContainer<SectionContent: View>(
        title: String,
        @ViewBuilder content: () -> SectionContent
    ) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top, 10)
            
            Divider()
            
            content()
                .padding(8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 4)
    }
}
