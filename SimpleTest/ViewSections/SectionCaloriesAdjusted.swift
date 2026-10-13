//
//  SectionCaloriesAdjusted.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

/// A view section displaying the final adjusted calorie targets.
struct SectionCaloriesAdjusted: View {

    let profile: ProfileViewModel
    let calculationResult: CalculatorResultViewModel

    var body: some View {

        VStack{
            HStack{
                Text("Calories (\(profile.calorieAdjustmentMethod.displayName))")
            }
            HStack{
                UICardNumericResult(title: "calories per day", value: calculationResult.caloriesAdjustedPerDay)
                UICardNumericResult(title: "calories per week", value: calculationResult.caloriesAdjustedPerWeek)
            }
        }.padding(16) // padding around the row

    }
}


#Preview {
    let calculationResult = CalculatorResultViewModel()
    calculationResult.caloriesAdjustedPerDay = 2000
    calculationResult.caloriesAdjustedPerWeek = 14000
    let profile = ProfileViewModel()
    return SectionCaloriesAdjusted(profile: profile, calculationResult: calculationResult)
}
