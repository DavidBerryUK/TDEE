//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionMacroMixResults: View {
        
    @Bindable var macroMixResults: MacroSplitResultViewModel
    
    var body: some View {
        
        VStack{
            HStack{
                Text("Macro Split")
            }
            HStack{
                UICardNumericResult(
                    title: "protein \(macroMixResults.proteinPercent)%",
                    value: Double( macroMixResults.proteinGrams),
                    suffix:"g"
                )
                
                UICardNumericResult(
                    title: "carbs \(macroMixResults.carbsPercent)%",
                    value: Double(  macroMixResults.carbsGrams),
                    suffix:"g"
                )
                UICardNumericResult(
                    title: "fats \(macroMixResults.fatsPercent)%",
                    value: Double(macroMixResults.fatsGrams),
                    suffix:"g"
                )
            }
        }.padding(16) // padding around the row
    }
}

#Preview {
    let macroMixResults = MacroSplitResultViewModel(
        proteinPercent: 40,
        carbsPercent: 20,
        fatsPercent: 20,
        proteinGrams: 450,
        carbsGrams: 210,
        fatsGrams: 80)
    
    return SectionMacroMixResults(macroMixResults: macroMixResults)
}
