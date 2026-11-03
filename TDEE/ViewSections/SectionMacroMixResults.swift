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
                    title: "protein",
                    value:  calculationResults.proteinGrams,
                    suffix:"g",
                    color: palette.macroProtein,
                    percent: calculationResults.proteinPercent,
                    equalizeHeight: true
                )

                UICardNumericResult(
                    title: "carbs",
                    value: calculationResults.carbsGrams,
                    suffix:"g",
                    color: palette.macroCarbs,
                    percent: calculationResults.carbsPercent,
                    equalizeHeight: true
                )
                UICardNumericResult(
                    title: "fats",
                    value: calculationResults.fatsGrams,
                    suffix:"g",
                    color: palette.macroFat,
                    percent: calculationResults.fatsPercent,
                    equalizeHeight: true
                )
            }
        }.padding(Spacing.large) // <-- Using central constant
    }
}

#Preview {
    let results = CalculatorResultViewModel();
    SectionMacroMixResults(calculationResults: results)
}
