//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionCaloriesAdjusted: View {
    
    @Bindable var profile : ProfileViewModel
    @Bindable var tdeeResult: TdeeResultViewModel
    
    
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
                    UICardNumericResult(title: "calories per day", value: tdeeResult.tdee * 2)
                    UICardNumericResult(title: "calories per week", value: tdeeResult.tdee * 7 * 2)
                }
            }.padding(16) // padding around the row
        }
    }
}


#Preview {
    let tdeeResult = TdeeResultViewModel()
    tdeeResult.tdee = 21
    let profile = ProfileViewModel()
    return SectionCaloriesAdjusted(profile: profile, tdeeResult: tdeeResult)
}
