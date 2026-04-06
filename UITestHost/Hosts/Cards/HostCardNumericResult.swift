//
//  HostCard.swift
//  UITestHost
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

struct HostCardNumericResult: View {
    
    @State private var caloriesPerDay: Double = 2500
    
    var body: some View {
        VStack{
            HStack{
                UICardNumericResult(title: "Calories per day", value: caloriesPerDay)
                UICardNumericResult(title: "Calories per week", value: caloriesPerDay * 7)
                
            }.padding(16)
            Slider(
                value: $caloriesPerDay,
                in: 0...5000,
                step: 1
            )
            .padding(16)
        }
    }
}

#Preview {
    HostCardNumericResult()
}
