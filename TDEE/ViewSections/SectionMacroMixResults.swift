//
//  SectionMacroMixResults.swift
//  TDEE
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

/// A view section displaying macro targets (protein, carbs, fats) in grams.
struct SectionMacroMixResults: View {
    @Environment(\.palette) private var palette

    @Bindable var calculationResults: CalculatorResultViewModel

    var body: some View {
        VStack{
            HStack{
                UICardNumericResult(
                    title: "protein \(calculationResults.proteinPercent)%",
                    value:  calculationResults.proteinGrams,
                    suffix:"g",
                    color: palette.macroProtein
                )

                UICardNumericResult(
                    title: "carbs \(calculationResults.carbsPercent)%",
                    value: calculationResults.carbsGrams,
                    suffix:"g",
                    color: palette.macroCarbs
                )
                UICardNumericResult(
                    title: "fats \(calculationResults.fatsPercent)%",
                    value: calculationResults.fatsGrams,
                    suffix:"g",
                    color: palette.macroFat
                )
            }
        }.padding(Spacing.large) // <-- Using central constant
    }
}

#Preview {
    let results = CalculatorResultViewModel();
    SectionMacroMixResults(calculationResults: results)
}
