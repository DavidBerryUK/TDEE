//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionCaloriesAdjusted: View {
    
    @Bindable var profile : ProfileViewModel
    @Bindable var macroResult: MacroSplitResultViewModel
    
    var body: some View {
                                
        UILayoutExpandingPanel(
            isOpen: $profile.calorieAdjustmentShowSliders,
            header: { EmptyView() }
        ) {
            VStack{
                HStack{
                    Text("Adjusted Calories")
                }
                HStack{
                    UICardNumericResult(title: "calories per day", value: macroResult.caloriesAdjustedPerDay)
                    UICardNumericResult(title: "calories per week", value: macroResult.caloriesAdjustedPerWeek)
                }
            }.padding(16) // padding around the row
        }
    }
}


#Preview {
    let macroResult = MacroSplitResultViewModel()
    macroResult.caloriesAdjustedPerDay = 2000
    macroResult.caloriesAdjustedPerWeek = 14000
    let profile = ProfileViewModel()
    return SectionCaloriesAdjusted(profile: profile, macroResult: macroResult)
}
