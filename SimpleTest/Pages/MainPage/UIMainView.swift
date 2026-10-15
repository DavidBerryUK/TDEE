//
//  MainView.swift
//  SimpleTest
//
//  Created by David Berry on 21/04/2026.
//

import SwiftUI
import Observation

struct UIMainView: View {
    @Binding var profile: ProfileViewModel
    @Binding var path: [AppRoute]
    @State private var calculationResult = CalculatorResultViewModel()
    @State var sectionManager = SectionManagerViewModel()

    @Environment(MacroSplitOptionsModelCollection.self) private var globalMacroCollection

    private func recalculate() async {
        calculationResult = await Calculator.calculate(person: profile)
    }

    var body: some View {
        VStack {
            ZStack {
                // Grey background (full screen)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollViewReader { outerProxy in
                        ScrollView {
                            VStack(spacing: 8) {
                                MainSectionProfileInput(
                                    profile: profile,
                                    sectionManager: sectionManager,
                                    proxy: outerProxy)

                                if ( profile.isValid) {
                                    VStack( spacing: 8) {
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
                                    } .transition(.opacity)

                                }
                            }
                            .animation(.easeInOut(duration: 0.25), value: profile.isValid)
                            .padding(.horizontal, geometry.size.width <= 375 ? 0 : 16)
                        }
                    }
                }
            }
            .task {
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
        }
    }
}

