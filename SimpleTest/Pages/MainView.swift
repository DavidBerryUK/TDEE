//
//  MainView.swift
//  SimpleTest
//
//  Created by David Berry on 21/04/2026.
//

import SwiftUI

struct MainView: View {
    private var profile = ProfileViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                // Grey background (full screen)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        //
                        // Input Section
                        //
                        VStack(spacing: 0) {
                            SectionGender(model: profile)
                            Divider()
                            SectionAge(model: profile)
                            Divider()
                            SectionHeight(model: profile)
                            Divider()
                            SectionWeight(model: profile)
                            Divider()
                            SectionActivityLevel(model: profile)
                            Divider()
                            SectionBodyFatPercentage(model: profile)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        //
                        // Results Section
                        //
                        VStack(spacing: 0) {
                            SectionCaloriesMaintenance(model: profile)
                            Divider()
                            SectionCalorieAdjustment(model: profile)
                            Divider()
                            SectionCaloriesAdjusted(model: profile)
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
                    }
                    .padding(16)
                    UICardValidation(model: profile)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    profile.collapseAll()
                }
            }
        }
    }
}
