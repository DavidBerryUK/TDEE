//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionMacroMixResults: View {
        
    @Bindable var calculationResults: CalculatorResultViewModel
    
    var body: some View {
        
        VStack{
            HStack{
                UICardNumericResult(
                    title: "protein \(calculationResults.proteinPercent)%",
                    value:  calculationResults.proteinGrams,
                    suffix:"g"
                )
                
                UICardNumericResult(
                    title: "carbs \(calculationResults.carbsPercent)%",
                    value: calculationResults.carbsGrams,
                    suffix:"g"
                )
                UICardNumericResult(
                    title: "fats \(calculationResults.fatsPercent)%",
                    value: calculationResults.fatsGrams,
                    suffix:"g"
                )
            }
        }.padding(16) // padding around the row
    }
}

#Preview {
    var results = CalculatorResultViewModel();
//    results.updateMacros(
//        proteinPercent: 40,
//        carbsPercent: 20,
//        fatsPercent: 20,
//        proteinGrams: 450,
//        carbsGrams: 210,
//        fatsGrams: 80,
//        caloriesAdjustedPerDay: 100,
//        caloriesAdjustedPerWeek: 700)
    
    SectionMacroMixResults(calculationResults: results)
}
