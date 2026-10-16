import SwiftUI

struct MainSectionProfileInput: View {
    @Bindable var profile: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {
        VStack(spacing: 12) {
            SectionGender(model: profile, sectionManager: sectionManager, proxy: proxy)
            SectionAge(model: profile, sectionManager: sectionManager, proxy: proxy)
            SectionHeight(model: profile, sectionManager: sectionManager, proxy: proxy)
            SectionWeight(model: profile, sectionManager: sectionManager, proxy: proxy)
            SectionActivityLevel(model: profile, sectionManager: sectionManager, proxy: proxy)
            SectionBodyFatPercentage(model: profile, sectionManager: sectionManager, proxy: proxy)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: profile.isWeightValid)
        .animation(.easeInOut(duration: 0.3), value: profile.isHeightValid)
    }
}

#Preview {
    MainSectionProfileInput(profile: ProfileViewModel(), sectionManager: SectionManagerViewModel(), proxy: nil)
}
