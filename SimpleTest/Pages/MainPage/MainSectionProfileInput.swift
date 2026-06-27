import SwiftUI

struct MainSectionProfileInput: View {
    @Bindable var profile: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel

    var body: some View {
        VStack(spacing: 0) {
            SectionGender(model: profile, sectionManager: sectionManager)
            Divider()
            SectionAge(model: profile, sectionManager: sectionManager)
            Divider()
            SectionHeight(model: profile, sectionManager: sectionManager)
            Divider()
            SectionWeight(model: profile, sectionManager: sectionManager)
            Divider()
            SectionActivityLevel(model: profile, sectionManager: sectionManager)
            Divider()
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
