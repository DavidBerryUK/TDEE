//
//  SectionMacroMixResults.swift
//  TDEE
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

/// A view section displaying macro targets (protein, carbs, fats) in grams.
struct SectionMacroMixResults: View {

    @Bindable var calculationResults: CalculatorResultViewModel

    var body: some View {
        VStack{
            HStack{
                UICardNumericResult(
                    title: "protein \(calculationResults.proteinPercent)%",
                    value:  calculationResults.proteinGrams,
                    suffix:"g",
                    color: .red
                )

                UICardNumericResult(
                    title: "carbs \(calculationResults.carbsPercent)%",
                    value: calculationResults.carbsGrams,
                    suffix:"g",
                    color: .blue
                )
                UICardNumericResult(
                    title: "fats \(calculationResults.fatsPercent)%",
                    value: calculationResults.fatsGrams,
                    suffix:"g",
                    color: .mint
                )
            }
        }.padding(Spacing.large) // <-- Using central constant
    }
}

#Preview {
    let results = CalculatorResultViewModel();
    SectionMacroMixResults(calculationResults: results)
}
