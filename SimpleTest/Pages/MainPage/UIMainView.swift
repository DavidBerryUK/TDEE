//
//  MainView.swift
//  SimpleTest
//
//  Created by David Berry on 21/04/2026.
//

import SwiftUI
import Combine

struct UIMainView: View {
    @StateObject private var profile = ProfileViewModel()
    @State private var tdeeResult = TdeeResultViewModel()
    @StateObject var macroMix = MacroSplitViewModel()
    @StateObject var sectionManager = SectionManagerViewModel()
    @State private var macroMixResults = MacroSplitResultViewModel()
    
    private func recalculate() {
        tdeeResult = TdeeCalculator.calculate(person: profile)
        macroMixResults = MacroCalculator.calculate(person: profile, tdee: tdeeResult)
    }

    var body: some View {
        VStack {
            ZStack {
                // Grey background (full screen)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        MainSectionProfileInput(
                            profile: profile,
                            sectionManager: sectionManager)
                        
                        if ( profile.isValid) {
                            VStack( spacing: 8) {
                                MainSectionCaloriesAndAdjustments(
                                    profile: profile,
                                    tdeeResult: tdeeResult,
                                    sectionManager: sectionManager)
                                
                                MainSectionMacroMix(
                                    macroMix: macroMix,
                                    sectionManager: sectionManager,
                                    macroMixResults: macroMixResults)
                            } .transition(.opacity)
                                
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: profile.isValid)
                    .padding(EnumDevice.isSmallScreen ? 0 : 16)
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
        }
    }
}

