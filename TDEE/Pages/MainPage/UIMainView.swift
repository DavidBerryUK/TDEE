//
//  MainView.swift
//  TDEE
//
//  Created by David Berry on 21/04/2026.
//

import SwiftUI
import UIKit
import Observation

struct UIMainView: View {
    @Environment(\.palette) private var palette
    @Environment(ThemeManager.self) private var themeManager
    @Binding var profile: ProfileViewModel
    @Binding var path: [AppRoute]
    @State private var calculationResult = CalculatorResultViewModel()
    @State private var isCalculating = true
    @State var sectionManager = SectionManagerViewModel()
    var presentationHandler: ((ShareContent) -> Void)?

    @Environment(MacroSplitOptionsModelCollection.self) private var globalMacroCollection
    @Environment(ProfileStore.self) private var profileStore

    // Update profile's macro collection to use the environment-injected one
    private func updateProfileMacroCollection() {
        profile.macroCollection = globalMacroCollection
    }

    /// The selected preset's split, so edits to it (not just selection changes) can be detected.
    /// MacroSplitOptionModel equality is by id only, so observing `items` misses value edits.
    private var selectedMacroSplit: [Int] {
        guard let selected = globalMacroCollection.items.first(where: { $0.id == profile.selectedMacroId }) else { return [] }
        return [selected.protein, selected.carbs, selected.fats]
    }

    private func syncEditedMacro() {
        guard let selected = globalMacroCollection.items.first(where: { $0.id == profile.selectedMacroId }) else { return }
        profile.syncMacros(from: selected)
    }

    /// Everything the result depends on. `.task(id:)` re-runs the calculation when this changes,
    /// replacing the former 11 per-field `.onChange` handlers — a single in-flight calc means
    /// `isCalculating` can't read stale under overlap. `split` is read from the *catalog* (the
    /// selected preset), so a value edit to the selected preset is detected, not just a selection.
    private struct Inputs: Hashable {
        var gender: Gender
        var age: Int
        var weight: Double
        var height: Double
        var activityLevel: ActivityLevel
        var bodyFatMethod: BodyFatOption
        var bodyFatPercentage: Double
        var adjustmentMethod: CalorieAdjustmentMethod
        var adjustment: Double
        var split: [Int]
    }

    private var inputs: Inputs {
        Inputs(
            gender: profile.gender,
            age: profile.age,
            weight: profile.weight,
            height: profile.height,
            activityLevel: profile.activityLevel,
            bodyFatMethod: profile.bodyFatPercentageMethod,
            bodyFatPercentage: profile.bodyFatPercentage,
            adjustmentMethod: profile.calorieAdjustmentMethod,
            adjustment: profile.calorieAdjustment,
            split: selectedMacroSplit)
    }

    private func share(_ format: ShareContent.Format) {
        guard profile.isValid else { return }
        // Trigger a fresh recalculation before sharing
        Task {
            await recalculate()
            let shareModel = profile.createShareResultsModel(result: calculationResult)
            presentationHandler?(ShareContent.make(format, model: shareModel, result: calculationResult, theme: themeManager.theme))
        }
    }

    private func recalculate() async {
        isCalculating = true
        calculationResult = await Calculator.calculate(person: profile)
        isCalculating = false
    }

    private var mainContent: some View {
        GeometryReader { geometry in
            ScrollViewReader { outerProxy in
                ScrollView {
                    mainSections(proxy: outerProxy)
                        .frame(maxWidth: 560)   // cap the column on wide screens (iPad)
                        .frame(maxWidth: .infinity)  // centre the capped column
                        .animation(.easeInOut(duration: 0.25), value: profile.isValid)
                        .padding(.horizontal, geometry.size.width <= 375 ? 0 : 16)
                }
            }
        }
    }

    private func mainSections(proxy outerProxy: ScrollViewProxy) -> some View {
        VStack(spacing: 8) {
            MainSectionProfileInput(
                profile: profile,
                sectionManager: sectionManager,
                proxy: outerProxy)

            if profile.isValid {
                VStack(spacing: 8) {
                    MainSectionCaloriesAndAdjustments(
                        profile: profile,
                        calculationResult: calculationResult,
                        sectionManager: sectionManager,
                        outerScrollViewProxy: outerProxy)

                    MainSectionMacroMix(
                        profile: profile,
                        sectionManager: sectionManager,
                        calculationResult: calculationResult,
                        path: $path,
                        outerScrollViewProxy: outerProxy)
                }
                .transition(.opacity)
            }
        }
    }

    var body: some View {
        VStack {
            ZStack {
                palette.background
                    .ignoresSafeArea()

                mainContent
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Share Image", systemImage: "photo") {
                            share(.image)
                        }
                        Button("Share Text", systemImage: "text.alignleft") {
                            share(.text)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share calculation results")
                    .disabled(!profile.isValid || isCalculating)
                }
                // One keyboard "Done" for the whole screen. Co-present numeric entries (height, body-fat
                // %, calorie adjustment) all render in this view at once and share the keyboard
                // accessory view, so each carrying its own `.keyboard` item rendered duplicate "Done"
                // buttons. A single screen-level Done resigns the current first responder instead.
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        // Resign whatever field is first responder and dismiss the keyboard — no
                        // per-field focus to track, so one button covers every entry on the screen.
                        UIApplication.shared.endEditing()
                    }
                }
            }
            // One reactive dependency drives every recompute, the way WatchMainView's `.task(id:)` does:
            // cancel the in-flight calc and run the latest when `inputs` changes — a single calculation
            // in flight means `isCalculating` can't read stale under overlap.
            .task(id: inputs) {
                updateProfileMacroCollection()
                syncEditedMacro()            // keep profile.split in step with the catalog's selected preset
                await recalculate()
            }
            // Tap outside any field — the background, the gaps between sections — ends the edit:
            // resign the current first responder so the keyboard dismisses, and collapse the sections.
            // A child field or section header consumes its own tap, so only taps that fall through to
            // this screen-level layer fire; the keyboard never dismisses on a header or field tap.
            .onTapGesture {
                // A child field or section header consumes its own tap, so this fires on a tap that
                // falls through to the screen layer — end the edit there, and collapse the sections.
                UIApplication.shared.endEditing()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    sectionManager.collapseAll()
                }
            }
            // Switching profiles re-points the shared view model (an async load); its per-field inputs
            // change afterwards, so the recompute flows through the `.task(id:)` above.
            .onChange(of: profileStore.activeProfileId) { _, id in
                Task { await profile.switchProfile(to: id) }
            }
        }
    }
}

