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
    
    func setUpData() {
        // generic
        model.gender = .male
        model.age = 34
        
        // kg
        modelKg.weightUom = .kilograms
        
        // pounds
        modelPounds.weightUom = .pounds
        modelPounds.weight = ConversionUtility.toKilograms(pounds: 95)
        
        // stones and pounds
        modelStonesAndPounds.weightUom = .stonesAndPounds
        modelStonesAndPounds.weight = ConversionUtility.toKilograms(stones: 15, pounds: 7)
    }
    
    var body: some View {
        VStack{
            UITextAgeValueView(model: $model)
            UITextValueGenderView(model: $model)
        }.onAppear{setUpData()}
    }
}

#Preview {
    NavigationStack {
        HostTextValuesGallery()
    }
}
