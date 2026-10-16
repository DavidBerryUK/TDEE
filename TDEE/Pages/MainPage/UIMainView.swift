//
//  MainView.swift
//  TDEE
//
//  Created by David Berry on 21/04/2026.
//

import SwiftUI
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
            }
            .task {
                // Inject the environment macro collection before calculating so it uses the user's presets
                updateProfileMacroCollection()
                await recalculate()
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    sectionManager.collapseAll()
                }
            }
            .onChange(of: profile.gender) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.age) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.weight) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.height) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.bodyFatPercentageMethod) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.bodyFatPercentage) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.calorieAdjustmentMethod) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.calorieAdjustment) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: profile.selectedMacroId) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: globalMacroCollection.items) { _, _ in
                Task { await recalculate() }
            }
            .onChange(of: selectedMacroSplit) { _, _ in
                syncEditedMacro()
                Task { await recalculate() }
            }
        }
    }
}

