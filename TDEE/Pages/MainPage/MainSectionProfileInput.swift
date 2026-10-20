import SwiftUI

/// The main input screen's "section factory" (story 023).
///
/// One section per input, chosen by that input's Classic/New preference in `InputStyleManager`.
/// Each section view carries a style suffix (`AgeClassicSectionView` / `AgeNewSectionView`);
/// every input currently resolves to its Classic control, and each New control drops into its
/// input's `.new` case as it's designed — one input at a time.
struct MainSectionProfileInput: View {
    @Environment(\.palette) private var palette
    @Environment(InputStyleManager.self) private var inputStyle
    @Bindable var profile: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {
        VStack(spacing: 12) {
            sections
        }
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: profile.isWeightValid)
        .animation(.easeInOut(duration: 0.3), value: profile.isHeightValid)
    }

    /// The sections, in display order — the surface the factory feeds to the main view.
    @ViewBuilder
    private var sections: some View {
        genderSection
        ageSection
        heightSection
        weightSection
        activityLevelSection
        bodyFatPercentageSection
    }

    @ViewBuilder
    private var genderSection: some View {
        switch inputStyle.style(for: .gender) {
        case .classic:
            GenderClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        case .new:
            // Story 023, input #1 — inline segmented control, no expand panel.
            GenderNewSectionView(model: profile)
        }
    }

    @ViewBuilder
    private var ageSection: some View {
        switch inputStyle.style(for: .age) {
        case .classic:
            AgeClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        case .new:
            // Story 023, input #2 — inline numeric text field, no expand panel.
            AgeNewSectionView(model: profile)
        }
    }

    @ViewBuilder
    private var heightSection: some View {
        // Story 023, inputs #5/#6 — the single height section composes two pieces that each honor
        // their own Classic/New toggle over the shared cm model (Decision 11). Any "New" toggle routes
        // to the composing section; all-Classic keeps today's expand/collapse wheel.
        let uomStyle = inputStyle.style(for: .heightUom)
        let valueStyle = inputStyle.style(for: .height)
        switch (uomStyle, valueStyle) {
        case (.classic, .classic):
            HeightClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        default:
            // The section reads both toggles itself to compose the switcher + value slots.
            HeightNewSectionView(model: profile)
        }
    }

    @ViewBuilder
    private var weightSection: some View {
        // Story 023, inputs #3/#4 — the single weight section composes two pieces that each honor
        // their own Classic/New toggle over the shared kg model (Decision 11). Any "New" toggle routes
        // to the composing section; all-Classic keeps today's expand/collapse wheel.
        let uomStyle = inputStyle.style(for: .weightUom)
        let valueStyle = inputStyle.style(for: .weight)
        switch (uomStyle, valueStyle) {
        case (.classic, .classic):
            WeightClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        default:
            // The section reads both toggles itself to compose the switcher + value slots.
            WeightNewSectionView(model: profile)
        }
    }

    @ViewBuilder
    private var activityLevelSection: some View {
        switch inputStyle.style(for: .activityLevel) {
        case .classic:
            ActivityLevelClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        case .new:
            // Story 023, input #9 — neutral menu button in the header, no expand panel.
            ActivityLevelNewSectionView(model: profile)
        }
    }

    @ViewBuilder
    private var bodyFatPercentageSection: some View {
        switch inputStyle.style(for: .bodyFatPercentage) {
        case .classic:
            BodyFatPercentageClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        case .new:
            // Story 023, input #7 — BodyFatPercentageNewSectionView (not built yet); falls back to Classic.
            BodyFatPercentageClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        }
    }
}

#Preview {
    MainSectionProfileInput(profile: ProfileViewModel(), sectionManager: SectionManagerViewModel(), proxy: nil)
        .environment(InputStyleManager())
}
