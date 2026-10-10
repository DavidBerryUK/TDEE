//
//  MainView.swift
//  SimpleTest
//
//  Created by David Berry on 21/04/2026.
//

import SwiftUI

struct UIMainView: View {
    @State private var profile = ProfileViewModel()
    @State private var calculationResult = CalculatorResultViewModel()
    @State var macroMix = MacroSplitViewModel()
    @State var sectionManager = SectionManagerViewModel()

    @Environment(MacroSplitOptionsModelCollection.self) private var globalMacroCollection

    /// Sync the user's selected macro preset into profile so calculations use their choice.
    private func syncSelectedMacro() {
        if let selected = globalMacroCollection.items.first(where: { $0.id == macroMix.selectedMacroId }) {
            profile.syncMacros(from: selected)
        }
    }

    private func recalculate() {
        syncSelectedMacro()
        calculationResult = Calculator.calculate(person: profile)
    }

    var body: some View {
        VStack {
            ZStack {
                // Grey background (full screen)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 8) {
                            MainSectionProfileInput(
                                profile: profile,
                                sectionManager: sectionManager)
                            
                            if ( profile.isValid) {
                                VStack( spacing: 8) {
                                    MainSectionCaloriesAndAdjustments(
                                        profile: profile,
                                        calculationResult: calculationResult,
                                        sectionManager: sectionManager)
                                    
                                    MainSectionMacroMix(
                                        macroMix: macroMix,
                                        sectionManager: sectionManager,
                                        calculationResult: calculationResult)
                                } .transition(.opacity)
                                
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: profile.isValid)
                        .padding(.horizontal, geometry.size.width <= 375 ? 0 : 16)
                    }
                }
            }
            .task {
                recalculate()
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    sectionManager.collapseAll()
                }
            }
            .onChange(of: profile.gender) { _, _ in
                recalculate()
            }
            .onChange(of: profile.age) { _, _ in
                recalculate()
            }
            .onChange(of: profile.weight) { _, _ in
                recalculate()
            }
            .onChange(of: profile.height) { _, _ in
                recalculate()
            }
            .onChange(of: profile.bodyFatPercentageMethod) { _, _ in
                recalculate()
            }
            .onChange(of: profile.bodyFatPercentage) { _, _ in
                recalculate()
            }
            .onChange(of: profile.calorieAdjustmentMethod) { _, _ in
                recalculate()
            }
            .onChange(of: profile.calorieAdjustment) { _, _ in
                recalculate()
            }
            .onChange(of: macroMix.selectedMacroId) { _, _ in
                recalculate()
            }
        }
    }
}

