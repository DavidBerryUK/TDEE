//
//  SectionMacroMixResults.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//
import SwiftUI
import SimpleTest.Constants.Spacing // Correctly imported spacing constants

struct SectionMacroMixResults: View {

    @Bindable var calculationResults: CalculatorResultViewModel // Assuming this type exists

    var body: some View {

        VStack{
            HStack{
                UICardNumericResult( // Assuming this view/type exists
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
        }.padding(Spacing.large) // <-- REFACTORED: Using central constant
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