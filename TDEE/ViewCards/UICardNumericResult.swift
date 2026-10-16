//
//  UICardNumericResult.swift
//  TDEE
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

/// A numeric result card displaying a value with a title and optional suffix.
struct UICardNumericResult: View {
    @Environment(\.palette) private var palette

    /// The descriptive title for this result
    var title : String
    /// The numeric value to display
    var value : Int
    /// An optional suffix to append to the value (e.g., "g" for grams)
    var suffix : String = ""
    /// An optional color for the card border and background tint
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
                .fill(color?.opacity(0.1) ?? palette.textSecondary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color ?? palette.highlight, lineWidth: 1.5)
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
