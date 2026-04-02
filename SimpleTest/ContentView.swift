import SwiftUI

struct ContentView: View {
    
    
    
    @StateObject private var profile = ProfileInputViewModel()

    var body: some View {
        
        TestHostCatalogView()

    }
}

#Preview {
    ContentView()
}


//
//        ScrollView {
//            VStack(alignment: .leading, spacing: 12) {
//                SectionGenderView(model: profile)
//                SectionAgeView(model: profile)
//                SectionHeightView(model: profile)
//                SectionWeightView(model: profile)
//
//
////                ExpandableSectionView(model: profile.activity, section: AppEnums.enumSection.activityLevel)
////                ExpandableSectionView(model: profile.bodyFat, section: AppEnums.enumSection.bodyFat)
//                CalculationResultsView(profile: profile)
//            }
//            .padding()
//        }
//        .background(Color(.systemGroupedBackground).ignoresSafeArea())
//        .onTapGesture {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                profile.collapseAll()
//            }
//        }
