import SwiftUI

struct ContentView: View {
    
    private var profile = ProfileInputViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                // Grey background (full screen)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 6) {
                            SectionGender(model: profile)
                            Divider()
                            SectionAge(model: profile)
                            Divider()
                            SectionWeight(model: profile)
                            Divider()
                            SectionHeight(model: profile)
                            Divider()
                            SectionActivityLevel(model: profile)
                            Divider()
                            SectionBodyFatPercentage(model: profile)
                            
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                    }
                    .padding(16)
                    SectionValidation(model: profile)
                }               
            }.onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    profile.collapseAll()
                }
            }
  
        }
    }
}

#Preview {
    ContentView()
}
