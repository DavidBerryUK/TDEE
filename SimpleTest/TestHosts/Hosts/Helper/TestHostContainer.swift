import SwiftUI

/// Reusable host container with modern tinted background and white hosted control
struct TestHostContainer<Content: View>: View {
    let title: String
    let instructions: String
    let content: () -> Content
    
    var body: some View {
        ZStack {
            // Page background
            Color.blue.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
//                // Title
//                Text(title)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.top, 20)
                
                // Instructions
                Text(instructions)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Hosted control container
                VStack {
                    Text("Hosted Control")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    Divider()
                    
                    content()
                        .padding(2)
                    
                }
                .background(Color.white) // White background for hosted control
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal,4)
                
                Spacer()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
