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

    var body: some View {
        VStack {
            // Initial calculation
            Color.clear.frame(height: 0).task {
                tdeeResult = TdeeCalculator.calculate(person: profile)
            }
            ZStack {
                // Grey background (full screen)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        //
                        // Section - Person Profile Input
                        //
                        VStack(spacing: 0) {
                            SectionGender(model: profile, sectionManager: sectionManager)
                            Divider()
                            SectionAge(model: profile, sectionManager: sectionManager)
                            Divider()
                            SectionHeight(model: profile, sectionManager: sectionManager)
                            Divider()
                            SectionWeight(model: profile, sectionManager: sectionManager)
                            Divider()
                            SectionActivityLevel(model: profile, sectionManager: sectionManager)
                            Divider()
                            SectionBodyFatPercentage(model: profile, sectionManager: sectionManager)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        //
                        // Section - Calories and Adjustments
                        //
                        VStack(spacing: 0) {
                            SectionCaloriesMaintenance(tdeeResult: tdeeResult)
                            Divider()
                            SectionCalorieAdjustment(model: profile, sectionManager: sectionManager)
                            Divider()
                            SectionCaloriesAdjusted(profile: profile, tdeeResult: tdeeResult)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .frame(
                            maxHeight: profile.isValid ? .infinity : 0,
                            alignment: .top
                        )
                        .clipped()
                        .opacity(profile.isValid ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25), value: profile.isValid)
                        
                        //
                        // Section - Macro Mix
                        //
                        VStack(spacing: 0) {
                            Divider()
                            SectionMacroMix(macroMix: macroMix, sectionManager: sectionManager)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .clipped()
                        
                        
                    }
                    .padding(16)
                    UICardValidation(model: profile)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    sectionManager.collapseAll()
                }
            }
            .onChange(of: profile.gender) { _, _ in
                tdeeResult = TdeeCalculator.calculate(person: profile)
            }
            .onChange(of: profile.age) { _, _ in
                tdeeResult = TdeeCalculator.calculate(person: profile)
            }
            .onChange(of: profile.weight) { _, _ in
                tdeeResult = TdeeCalculator.calculate(person: profile)
            }
            .onChange(of: profile.height) { _, _ in
                tdeeResult = TdeeCalculator.calculate(person: profile)
            }
            .onChange(of: profile.bodyFatPercentageMethod) { _, _ in
                tdeeResult = TdeeCalculator.calculate(person: profile)
            }
            .onChange(of: profile.bodyFatPercentage) { _, _ in
                tdeeResult = TdeeCalculator.calculate(person: profile)
            }
        }
    }
}

