//
//  UICardNumericResult.swift
//  SimpleTest
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

struct UICardNumericResult: View {

    var title : String
    var value : Int
    var suffix : String = ""
    var color : Color? = nil

    var body: some View {

        VStack(alignment: .center, spacing: 6.0) {
            HStack(alignment: .firstTextBaseline,spacing:0) {
                Text("\(Int(value))")
                    .font(.largeTitle)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: value)
                Text(suffix)
            }
            Text(title)
                .font(.callout)
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color?.opacity(0.1) ?? Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color ?? Color(red: 0.25, green: 0.75, blue: 0.75), lineWidth: 1)
        )
    }
}

#Preview {
    VStack{
        HStack{
            UICardNumericResult(title: "Calories per day", value: 2500)
            UICardNumericResult(title: "Calories per week", value: 2500 * 7)
        }
        HStack{
            UICardNumericResult(title: "Carbs", value: 230, suffix:"g", color: .blue)
            UICardNumericResult(title: "Fats", value: 142, suffix:"g", color: .mint)
            UICardNumericResult(title: "Protien", value: 222, suffix:"g", color: .red)
        }
    }.padding(8)
}
