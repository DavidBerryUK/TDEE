import SwiftUI

struct MainSectionCaloriesAndAdjustments: View {
    let profile: ProfileViewModel
    let calculationResult: CalculatorResultViewModel
    let sectionManager: SectionManagerViewModel
    

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                SectionCaloriesAdjusted(profile: profile, calculationResult: calculationResult)
                Divider()
                SectionCalorieAdjustment(profile: profile, sectionManager: sectionManager)
                    .id("CalorieAdjustment")
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
                    sectionManager.calorieAdjustmentExpanded.toggle()
                }
            }
            .onChange(of: profile.calorieAdjustmentMethod) { _, newValue in
                handleCalorieAdjustmentChange(newValue: newValue, proxy: proxy)
            }
            .onChange(of: sectionManager.calorieAdjustmentExpanded) { _, _ in
                scrollIfNecessary(proxy: proxy)
            }
        }
    }

    private func handleCalorieAdjustmentChange(newValue: enumCalorieAdjustmentMethod, proxy: ScrollViewProxy) {
        if newValue == .cut || newValue == .bulk {
            scrollIfNecessary(proxy: proxy)
        }
    }

    private func scrollIfNecessary(proxy: ScrollViewProxy) {
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // Delay of 0.2 seconds (200 ms)
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo("CalorieAdjustment", anchor: .bottom) // Scroll to the anchor
            }
        }
    }
}

#Preview {
    MainSectionCaloriesAndAdjustments(
        profile: ProfileViewModel(),
        calculationResult: CalculatorResultViewModel(),
        sectionManager: SectionManagerViewModel()
    )
}
