import SwiftUI

struct ContentView: View {
    @StateObject private var sectionAge = SectionAgeViewModel()
    @StateObject private var sectionHeight = SectionHeightViewModel()
    @StateObject private var sectionActivityLevel = SectionActivityLevelViewModel()
    @StateObject private var sectionWeight = SectionWeightViewModel()
    @StateObject private var sectionBodyFat = SectionBodyFatViewModel()
    @StateObject private var sectionGender = SectionGenderViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ExpandableSectionView(model: sectionGender)
                ExpandableSectionView(model: sectionAge)
                ExpandableSectionView(model: sectionHeight)
                ExpandableSectionView(model: sectionWeight)
                ExpandableSectionView(model: sectionActivityLevel)                
                ExpandableSectionView(model: sectionBodyFat)
                CalculationResultsView()
              
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
