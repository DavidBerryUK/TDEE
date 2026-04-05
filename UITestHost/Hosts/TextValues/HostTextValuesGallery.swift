//
//  SwiftUIView.swift
//  UITestHost
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct HostTextValuesGallery: View {
    
    @State private var model: ProfileInputViewModel = ProfileInputViewModel()
    @State private var modelKg: ProfileInputViewModel = ProfileInputViewModel()
    @State private var modelPounds: ProfileInputViewModel = ProfileInputViewModel()
    @State private var modelStonesAndPounds: ProfileInputViewModel = ProfileInputViewModel()
    
    @State private var modelCm: ProfileInputViewModel = ProfileInputViewModel()
    @State private var modelInches: ProfileInputViewModel = ProfileInputViewModel()
    @State private var modelFeedAndInches: ProfileInputViewModel = ProfileInputViewModel()
    
    init() {
        let base = ProfileInputViewModel()
        base.gender = .female
        base.age = 34
        _model = State(initialValue: base)
        
        let kg = ProfileInputViewModel()
        kg.weightUom = .kilograms
        _modelKg = State(initialValue: kg)
        
        let pounds = ProfileInputViewModel()
        pounds.weightUom = .pounds
        pounds.weight = WeightConvertor.toKilograms(pounds: 95)
        _modelPounds = State(initialValue: pounds)
        
        let stones = ProfileInputViewModel()
        stones.weightUom = .stonesAndPounds
        stones.weight = WeightConvertor.toKilograms(stones: 15, pounds: 7)
        _modelStonesAndPounds = State(initialValue: stones)
        
        let cm = ProfileInputViewModel()
        cm.heightUom = .centimeters
        cm.height = 120
        _modelCm = State(initialValue: cm)
        
        let inches = ProfileInputViewModel()
        inches.heightUom = .inches
        inches.height = LengthConverter.toCentimeters(inches: 75)
        _modelInches = State(initialValue: inches)
        
        let feetAndInches = ProfileInputViewModel()
        feetAndInches.heightUom = .feetAndInches
        feetAndInches.height = LengthConverter.toCentimeters(feet: 6, inches: 2)
        _modelFeedAndInches = State(initialValue: feetAndInches)
    }
    
    var body: some View {
        VStack{
            UITextAgeValueView(model: $model)
            UITextValueGenderView(model: $model)
            UITextValueWeightValue(model: $modelKg)
            UITextValueWeightValue(model: $modelPounds)
            UITextValueWeightValue(model: $modelStonesAndPounds)
            UITextValueHeightValue(model: $modelCm)
            UITextValueHeightValue(model: $modelInches)
            UITextValueHeightValue(model: $modelFeedAndInches)
        }
    }
}

#Preview {
    NavigationStack {
        HostTextValuesGallery()
    }
}
