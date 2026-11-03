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
        inputCard
            .animation(.easeInOut(duration: 0.3), value: profile.isWeightValid)
            .animation(.easeInOut(duration: 0.3), value: profile.isHeightValid)
            // Body-fat expand/collapse: switching the method to Manual Entry grows the wheel in, so the
            // whole card animates its height. Uses the section's own open/close spring (springDefault) so
            // the inner picker panel and the card move identically — not the easeInOut the validity lines
            // above use. Covers both the Classic and New body-fat variants, as both sit under this container.
            .animation(AnimationParams.springDefault, value: profile.bodyFatPercentageMethod)
    }

    /// The input sections, either as one card (undressed themes) or as six self-drawing cards (a
    /// `sectionDressing` active, e.g. Pride — each `.sectionDressed(for:)` below draws its own card). When a
    /// dressing is active the outer card is suppressed so the rainbow reads as six distinct cards; otherwise
    /// the whole input is one card, exactly as before.
    @ViewBuilder
    private var inputCard: some View {
        let stack = VStack(spacing: 12) {
            sections
        }
        if palette.sectionDressing == nil {
            stack
                .background(palette.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        } else {
            stack
        }
    }

    /// The sections, in display order — each dressed with its own accent (a no-op for undressed themes).
    @ViewBuilder
    private var sections: some View {
        genderSection.sectionDressed(for: .gender)
        ageSection.sectionDressed(for: .age)
        heightSection.sectionDressed(for: .height)
        weightSection.sectionDressed(for: .weight)
        activityLevelSection.sectionDressed(for: .activityLevel)
        bodyFatPercentageSection.sectionDressed(for: .bodyFat)
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
        // Story 023, inputs #7/#8 — the single body-fat section composes two pieces that each honor
        // their own Classic/New toggle over the shared model (Decision 11 analog). Any "New" toggle
        // routes to the composing section; all-Classic keeps today's expand/collapse wheel.
        let methodStyle = inputStyle.style(for: .bodyFatMethod)
        let valueStyle = inputStyle.style(for: .bodyFatPercentage)
        switch (methodStyle, valueStyle) {
        case (.classic, .classic):
            BodyFatPercentageClassicSectionView(model: profile, sectionManager: sectionManager, proxy: proxy)
        default:
            // The section reads both toggles itself to compose the method + gated value slots.
            BodyFatPercentageNewSectionView(model: profile)
        }
    }
}

#Preview {
    MainSectionProfileInput(profile: ProfileViewModel(), sectionManager: SectionManagerViewModel(), proxy: nil)
        .environment(InputStyleManager())
}
