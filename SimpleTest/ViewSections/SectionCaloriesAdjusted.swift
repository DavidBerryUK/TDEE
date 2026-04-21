//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionCaloriesAdjusted: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        
        let tdee = model.tdeeResult
                
        UILayoutExpandingPanel(
            isOpen: $model.calorieAdjustmentShowSliders,
            header: { EmptyView() }
        ) {
            VStack{
                HStack{
                    Text("Adjusted Calories")
                }
                HStack{
                    UICardNumericResult(title: "calories per day", value: tdee.tdee * 2)
                    UICardNumericResult(title: "calories per week", value: tdee.tdee * 7 * 2)
                }
            }.padding(16) // padding around the row
        }
    }
}


#Preview {
    let model = ProfileViewModel()
    model.age = 21
    model.height = 80
    model.weight = 56
    return SectionCaloriesAdjusted(model: model)
}
