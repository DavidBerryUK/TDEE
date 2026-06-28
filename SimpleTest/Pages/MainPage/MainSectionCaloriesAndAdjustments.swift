import SwiftUI

struct MainSectionCaloriesAndAdjustments: View {
    let profile: ProfileViewModel
    let tdeeResult: TdeeResultViewModel
    let macroResult: MacroSplitResultViewModel
    let sectionManager: SectionManagerViewModel
    

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                SectionCaloriesMaintenance(tdeeResult: tdeeResult)
                    .id("CalorieMaintenance")
                Divider()
                SectionCalorieAdjustment(profile: profile, sectionManager: sectionManager)
                    .id("CalorieAdjustment")
                Divider()
                SectionCaloriesAdjusted(profile: profile, macroResult: macroResult)
                    .id("CalorieAdjusted")
                
             
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .frame(maxHeight: profile.isValid ? .infinity : 0, alignment: .top)
            .clipped()
            .opacity(profile.isValid ? 1 : 0)
            .animation(.easeInOut(duration: 0.25), value: profile.isValid)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    sectionManager.calorieAdjustmentExpanded = true;
                }
            }
            .onChange(of: sectionManager.calorieAdjustmentExpanded) { _, value in
                if value {
                    Task {
                        try? await Task.sleep(nanoseconds: 200_000_000) // Delay of 0.2 seconds (200 ms)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("CalorieAdjusted", anchor: .bottom) // Scroll to the anchor
                        }
                    }
                }
            }
        }
       
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
