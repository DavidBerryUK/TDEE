import SwiftUI

struct MainSectionCaloriesAndAdjustments: View {
    let profile: ProfileViewModel
    let calculationResult: CalculatorResultViewModel
    let sectionManager: SectionManagerViewModel
    let outerScrollViewProxy: ScrollViewProxy

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                SectionCaloriesAdjusted(profile: profile, calculationResult: calculationResult)
                Divider()
                SectionCalorieAdjustment(profile: profile, sectionManager: sectionManager, proxy: outerScrollViewProxy)
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
                handleCalorieAdjustmentChange(newValue: newValue)
            }
            .onChange(of: sectionManager.calorieAdjustmentExpanded) { _, _ in
                scrollIfNecessary()
            }
        }
    }

    private func handleCalorieAdjustmentChange(newValue: CalorieAdjustmentMethod) {
        if newValue == .cut || newValue == .bulk {
            scrollIfNecessary()
        }
    }

    private func scrollIfNecessary() {
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // Delay of 0.2 seconds (200 ms)
            withAnimation(.easeInOut(duration: 0.3)) {
                outerScrollViewProxy.scrollTo("CalorieAdjustment", anchor: .bottom)
            }
        }
    }
}

#Preview {
    // Preview disabled - requires ScrollViewProxy from outer ScrollViewReader
    EmptyView()
}
