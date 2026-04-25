//
//  SectionMaintenanceCalories.swift
//  SimpleTest
//
//  Created by David Berry on 08/04/2026.
//

import SwiftUI

struct SectionCaloriesMaintenance: View {
    
    
    @Bindable var tdeeResult: TdeeResultViewModel
    
    var body: some View {
        
        VStack{
            HStack{
                Text("Maintenance Calories")
            }
            HStack{
                UICardNumericResult(title: "calories per day", value: tdeeResult.tdee)
                UICardNumericResult(title: "calories per week", value: tdeeResult.tdee * 7)
            }
        }.padding(16) // padding around the row
    }
}

#Preview {
    let tdeeResult = TdeeResultViewModel()
    tdeeResult.tdee = 1200
    return SectionCaloriesMaintenance(tdeeResult: tdeeResult)
}
