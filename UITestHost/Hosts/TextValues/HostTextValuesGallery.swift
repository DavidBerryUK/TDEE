//
//  SwiftUIView.swift
//  UITestHost
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct HostTextValuesGallery: View {
    
    @State private var model: ProfileViewModel = ProfileViewModel()
    @State private var modelKg: ProfileViewModel = ProfileViewModel()
    @State private var modelPounds: ProfileViewModel = ProfileViewModel()
    @State private var modelStonesAndPounds: ProfileViewModel = ProfileViewModel()
    
    @State private var modelCm: ProfileViewModel = ProfileViewModel()
    @State private var modelInches: ProfileViewModel = ProfileViewModel()
    @State private var modelFeedAndInches: ProfileViewModel = ProfileViewModel()
    
    @State private var modelBodyFatOmit : ProfileViewModel = ProfileViewModel()
    @State private var modelBodyFatEstimated : ProfileViewModel = ProfileViewModel()
    @State private var modelBodyFatManualEntry : ProfileViewModel = ProfileViewModel()
    
    @State private var modelActivtyLevel : ProfileViewModel = ProfileViewModel()
    
    init() {
        let base = ProfileViewModel()
        base.gender = .female
        base.age = 34
        _model = State(initialValue: base)
        
        let kg = ProfileViewModel()
        kg.weightUom = .kilograms
        _modelKg = State(initialValue: kg)
        
        let pounds = ProfileViewModel()
        pounds.weightUom = .pounds
        pounds.weight = WeightConvertor.toKilograms(pounds: 95)
        _modelPounds = State(initialValue: pounds)
        
        let stones = ProfileViewModel()
        stones.weightUom = .stonesAndPounds
        stones.weight = WeightConvertor.toKilograms(stones: 15, pounds: 7)
        _modelStonesAndPounds = State(initialValue: stones)
        
        let cm = ProfileViewModel()
        cm.heightUom = .centimeters
        cm.height = 120
        _modelCm = State(initialValue: cm)
        
        let inches = ProfileViewModel()
        inches.heightUom = .inches
        inches.height = LengthConverter.toCentimeters(inches: 75)
        _modelInches = State(initialValue: inches)
        
        let feetAndInches = ProfileViewModel()
        feetAndInches.heightUom = .feetAndInches
        feetAndInches.height = LengthConverter.toCentimeters(feet: 6, inches: 2)
        _modelFeedAndInches = State(initialValue: feetAndInches)
        
        let omit = ProfileViewModel()
        omit.bodyFatPercentageMethod = .omit
        omit.bodyFatPercentage = 15.4
        _modelBodyFatOmit = State(initialValue: omit)
        
        let estimated = ProfileViewModel()
        estimated.bodyFatPercentageMethod = .estimate
        estimated.bodyFatPercentage = 15.4
        _modelBodyFatEstimated = State(initialValue: estimated)
        
        let manualEntry = ProfileViewModel()
        manualEntry.bodyFatPercentageMethod = .manualEntry
        manualEntry.bodyFatPercentage = 15.4
        _modelBodyFatManualEntry = State(initialValue: manualEntry)
        
        let modelActivtyLevel = ProfileViewModel()
        modelActivtyLevel.activityLevel = .heavyExercise
        _modelActivtyLevel = State(initialValue: modelActivtyLevel)
    }
    
    var body: some View {
        VStack{
            UISectionSummaryValueAge(model: model)
            UISectionSummaryValueGender(model: model)
            UISectionSummaryValueWeight(model: modelKg)
            UISectionSummaryValueWeight(model: modelPounds)
            UISectionSummaryValueWeight(model: modelStonesAndPounds)
            UISectionSummaryValueHeight(model: modelCm)
            UISectionSummaryValueHeight(model: modelInches)
            UISectionSummaryValueHeight(model: modelFeedAndInches)
            UISectionSummaryValueBodyFat(model: modelBodyFatOmit)
            UISectionSummaryValueBodyFat(model: modelBodyFatEstimated)
            UISectionSummaryValueBodyFat(model: modelBodyFatManualEntry)
            UISectionSummaryValueActivityLevel(model: modelActivtyLevel)
        }
    }
}

#Preview {
    NavigationStack {
        HostTextValuesGallery()
    }
}
