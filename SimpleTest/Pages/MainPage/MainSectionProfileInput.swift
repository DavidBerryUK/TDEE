import SwiftUI

struct MainSectionProfileInput: View {
    @Bindable var profile: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel

    var body: some View {
        VStack(spacing: 12) {
            SectionGender(model: profile, sectionManager: sectionManager)
            SectionAge(model: profile, sectionManager: sectionManager)
            SectionHeight(model: profile, sectionManager: sectionManager)
            SectionWeight(model: profile, sectionManager: sectionManager)
            SectionActivityLevel(model: profile, sectionManager: sectionManager)
            SectionBodyFatPercentage(model: profile, sectionManager: sectionManager)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: profile.isWeightValid)
        .animation(.easeInOut(duration: 0.3), value: profile.isHeightValid)
    }
}

#Preview {
    MainSectionProfileInput(profile: ProfileViewModel(), sectionManager: SectionManagerViewModel())
}
