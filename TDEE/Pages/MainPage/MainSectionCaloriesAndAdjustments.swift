import SwiftUI
import UIKit

struct MainSectionCaloriesAndAdjustments: View {
    @Environment(\.palette) private var palette
    @Environment(InputStyleManager.self) private var inputStyle
    let profile: ProfileViewModel
    let calculationResult: CalculatorResultViewModel
    let sectionManager: SectionManagerViewModel
    let outerScrollViewProxy: ScrollViewProxy

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                SectionCaloriesAdjusted(profile: profile, calculationResult: calculationResult)
                Divider()
                calorieAdjustmentSection
                    .id("CalorieAdjustment")
            }
            .background(palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .frame(maxHeight: profile.isValid ? .infinity : 0, alignment: .top)
            .clipped()
            .opacity(profile.isValid ? 1 : 0)
            .animation(.easeInOut(duration: 0.25), value: profile.isValid)
            .onTapGesture {
                // End any in-progress edit when tapping this panel (it consumes the tap, so the
                // screen-level fall-through handler in UIMainView never sees it).
                UIApplication.shared.endEditing()
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

    // Story 023, inputs #10 / #11 — the single calorie-adjustment section, routed by its two Classic/New
    // toggles over the shared model (Decision 11 analog). Any "New" toggle composes the new section;
    // all-Classic keeps today's expand/collapse wheel-free slider panel.
    @ViewBuilder
    private var calorieAdjustmentSection: some View {
        switch (inputStyle.style(for: .calorieAdjustmentMethod), inputStyle.style(for: .calorieAdjustment)) {
        case (.classic, .classic):
            SectionCalorieAdjustment(profile: profile, sectionManager: sectionManager, proxy: outerScrollViewProxy)
        default:
            CalorieAdjustmentNewSectionView(model: profile)
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
