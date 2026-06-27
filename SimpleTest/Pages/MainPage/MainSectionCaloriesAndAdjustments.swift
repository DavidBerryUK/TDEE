import SwiftUI

struct MainSectionCaloriesAndAdjustments: View {
    let profile: ProfileViewModel
    let tdeeResult: TdeeResultViewModel
    let macroResult: MacroSplitResultViewModel
    let sectionManager: SectionManagerViewModel
    

    var body: some View {
        VStack(spacing: 0) {
            SectionCaloriesMaintenance(tdeeResult: tdeeResult)
            Divider()
            SectionCalorieAdjustment(model: profile, sectionManager: sectionManager)
            Divider()
            SectionCaloriesAdjusted(profile: profile, macroResult:  macroResult)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .frame(maxHeight: profile.isValid ? .infinity : 0, alignment: .top)
        .clipped()
        .opacity(profile.isValid ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: profile.isValid)
    }
}

#Preview {
    MainSectionCaloriesAndAdjustments(
        profile: ProfileViewModel(),
        tdeeResult: TdeeResultViewModel(),
        macroResult: MacroSplitResultViewModel(),
        sectionManager: SectionManagerViewModel()
    )
}
