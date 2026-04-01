import SwiftUI

struct ContentView: View {
    @StateObject private var sectionA = SectionAgeViewModel()
    @StateObject private var sectionB = SectionHeightViewModel()
    @StateObject private var sectionC = SectionActivityLevelViewModel()
    @StateObject private var sectionD = SectionWeightViewModel()
    @StateObject private var sectionE = SectionBodyFatViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ExpandableSectionView(model: sectionA)
                ExpandableSectionView(model: sectionB)
                ExpandableSectionView(model: sectionC)
                ExpandableSectionView(model: sectionD)
                ExpandableSectionView(model: sectionE)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
